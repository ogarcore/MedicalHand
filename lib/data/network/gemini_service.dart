import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:p_hn25/app/core/constants/api_keys.dart';
import 'package:p_hn25/data/models/message_model.dart';

class GeminiService {
  final String _apiKey = geminiApiKey;

  final String _model = 'models/gemini-2.5-flash';

  Future<String> generateContent(List<Message> history, String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/$_model:generateContent?key=$_apiKey',
    );

    // Instrucción del sistema
    final systemInstruction = {
      "role": "system",
      "parts": [
        {
          "text": """
Eres un asistente de salud virtual para MedicalHand, una aplicación nicaragüense para agendar citas médicas.
Se un poco mas extenso en tus respuestas porfavor, Y haz las respuestas algo mas detalladas.

Tus capacidades principales son las siguientes.

Primero, dar consejos de bienestar. Ofrece consejos generales sobre hidratación, ejercicio, dieta balanceada y hábitos saludables.

Segundo, guía a los usuarios sobre el uso de la app. Ayúdales a entender cómo utilizar MedicalHand de manera sencilla. Para agendar una nueva cita, explícales que deben ingresar a la sección “Agendar Cita”. Allí encontrarán disponible la opción de Cita de Consulta General, ya que la atención está configurada automáticamente en la Clínica Sierra Maestra.

Indícales que deben seleccionar la cita de Consulta General, escribir el motivo de su consulta y continuar. Finalmente, la aplicación les mostrará un resumen con los detalles ingresados antes de confirmar la solicitud.

También puedes orientarles sobre cómo revisar sus citas en la sección “Mis Citas” y consultar su historial básico en el apartado “Mi Historial”.

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
        "role": msg.role, // 'user' o 'assistant' u otro rol
        "parts": [
          {"text": msg.text}
        ],
      };
    }).toList();

    // Añadimos el mensaje actual del usuario
    contents.add({
      "role": "user",
      "parts": [
        {"text": prompt}
      ],
    });

    final bodyJson = {
      "system_instruction": systemInstruction,
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
      ]
    };

    final body = json.encode(bodyJson);

    // Lógica de reintentos en caso de errores transitorios
    const int maxRetries = 3;
    int delaySeconds = 1;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final decoded = json.decode(utf8.decode(response.bodyBytes));
          final candidates = decoded['candidates'];
          if (candidates != null && candidates is List && candidates.isNotEmpty) {
            final first = candidates[0];
            final content = first['content'];
            if (content != null && content['parts'] != null) {
              final parts = content['parts'];
              if (parts is List && parts.isNotEmpty) {
                final part0 = parts[0];
                final text = part0['text'];
                if (text != null && text is String && text.isNotEmpty) {
                  return text;
                }
              }
            }
          }
          return 'No se recibió una respuesta válida del modelo.';
        } else if (response.statusCode == 429) {
          // error de cuota o límite de peticiones
          if (attempt == maxRetries - 1) {
            return 'Límite de cuota excedido (Error 429). Por favor revisa los límites de tu API Key o si está siendo usada por muchas personas.';
          }
          await Future.delayed(Duration(seconds: delaySeconds));
          delaySeconds *= 2;
        } else if (response.statusCode == 503) {
          // error de servicio ocupado
          if (attempt == maxRetries - 1) {
            return 'El servicio está ocupado de parte de Google. Inténtalo nuevamente en unos momentos.';
          }
          await Future.delayed(Duration(seconds: delaySeconds));
          delaySeconds *= 2;
        } else {
          // error definitivo
          return 'Ocurrió un error (${response.statusCode}). Por favor inténtalo de nuevo.';
        }
      } catch (e) {
        if (attempt == maxRetries - 1) {
          return 'No se pudo conectar con el servicio de asistencia. Revisa tu conexión.';
        }

        await Future.delayed(Duration(seconds: delaySeconds));
        delaySeconds *= 2;
      }
    }

    return 'No se obtuvo respuesta después de varios intentos.';
  }
}
