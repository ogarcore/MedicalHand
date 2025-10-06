import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:p_hn25/app/core/constants/api_keys.dart';
import 'package:p_hn25/data/models/message_model.dart';

class GeminiService {
  final String _apiKey = geminiApiKey;
  // Modelo actualizado a Gemini 2.5 Flash
  final String _model = 'gemini-2.5-flash';

  Future<String> generateContent(List<Message> history, String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    // Instrucción del sistema
    const systemInstruction = {
      "role": "system",
      "parts": [
        {
          "text": """
          Eres un asistente de salud virtual para MedicalHand, una aplicación nicaragüense para agendar citas médicas.

          Tus capacidades principales son las siguientes.

          Primero, dar consejos de bienestar. Ofrece consejos generales sobre hidratación, ejercicio, dieta balanceada y hábitos saludables.

          Segundo, guiar sobre el uso de la app. Ayuda a los usuarios a entender cómo usar MedicalHand. Para agendar una nueva cita, explícales que deben ir a la sección 'Agendar Cita'. Detalla que el proceso les pedirá seleccionar primero su ubicación o departamento, luego el hospital de su preferencia que esté disponible en esa zona, y finalmente escribir el motivo de su consulta. También puedes explicarles cómo revisar su historial de citas en la sección 'Mis Citas' y su historial basico en el apartado de mi historial.

          Tercero, orientar sobre síntomas con mucha precaución. Puedes interpretar síntomas de manera general y educativa. Por ejemplo, si alguien menciona 'dolor de cabeza y congestión', puedes explicar que 'comúnmente esos síntomas se asocian a resfriados o alergias'.

          Tus reglas y prohibiciones ESTRICTAS son:
          - NUNCA dar un diagnóstico médico directo. Tienes prohibido decir 'Usted tiene gripe'.
          - NUNCA recetar o sugerir dosis de medicamentos.
          - Si un usuario describe síntomas graves como dolor en el pecho, dificultad para respirar, etc., tu prioridad absoluta es indicarle que busque atención médica de emergencia de inmediato.
          - Toda respuesta que involucre la interpretación de síntomas DEBE terminar OBLIGATORIAMENTE con una advertencia clara como: 'Recuerda, esto no es un diagnóstico. Te recomiendo agendar una cita en la app para que un profesional pueda evaluarte correctamente.'

          Mantén siempre un tono amigable, profesional y claro. No uses asteriscos ni ningún formato especial en tus respuestas.
        """
        }
      ]
    };

    // Construcción del historial de mensajes
    final contents = history.map((msg) {
      return {
        "role": msg.role, // 'user' o 'model'
        "parts": [
          {"text": msg.text}
        ]
      };
    }).toList();

    // Añadimos el mensaje actual
    contents.add({
      "role": "user",
      "parts": [
        {"text": prompt}
      ]
    });

    final body = json.encode({
      "system_instruction": systemInstruction, // ✅ la API usa snake_case
      "contents": contents,
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final text =
            decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return text.isNotEmpty
            ? text
            : 'No se recibió una respuesta del asistente.';
      } else {
        print('Error en la API de Gemini: ${response.body}');
        return 'Lo siento, ocurrió un error (${response.statusCode}).';
      }
    } catch (e) {
      print('Error de red al conectar con Gemini: $e');
      return 'No se pudo conectar con el asistente. Revisa tu conexión a internet.';
    }
  }
}
