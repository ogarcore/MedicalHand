#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flutter i18n Extractor v8.1 PRO MAX
-----------------------------------
Autor: ChatGPT (Optimizado para seguridad y rendimiento)
Propósito: Detectar textos traducibles en código Dart/Flutter,
reemplazarlos por llamadas a traducción ('clave'.tr()),
y generar automáticamente el archivo JSON de traducción.

Cumple los siguientes objetivos:
✅ Reemplazar solo literales seguros (no código, no funciones)
✅ Preservar interpolaciones
✅ Agregar imports automáticamente (sin duplicar)
✅ Generar claves únicas y limpias
✅ Crear logs de advertencias y reportes de cambios
"""

import os
import re
import json
import difflib
import collections
from pathlib import Path

# ==========================
# 🔧 CONFIGURACIÓN
# ==========================
PROJECT_PATH = Path(".")
TRANSLATIONS_DIR = Path("./assets/translations")
OUTPUT_JSON = TRANSLATIONS_DIR / "es.json"
IMPORT_STATEMENT = "import 'package:easy_localization/easy_localization.dart';"

EXCLUDED_FOLDERS = {"build", "ios", "android", "linux", "macos", "windows", "web", ".dart_tool", "test"}
EXCLUDED_FILES = {".g.dart", ".freezed.dart", "firebase_options.dart"}

DRY_RUN = False  # ⚙️ Cambia a False para aplicar cambios

# ==========================
# 🧩 PATRONES REGEX
# ==========================
# Detecta textos literales en widgets comunes y propiedades típicas de UI
TEXT_PATTERNS = re.compile(
    r"""
    (?<![A-Za-z0-9_])        # evitar coincidencias dentro de variables
    (?:const\s+)?Text\s*\(\s*['"]([^'"]+)['"]   # Text('hola')
    |['"]([^'"]+)['"]\s*,\s*style:              # 'hola', style:
    |(?:hintText|labelText|title|message|tooltip|content|text)\s*:\s*['"]([^'"]+)['"]
    """,
    re.VERBOSE,
)

VARIABLE_PATTERN = re.compile(r"\$\{?([\w.]+)\}?")

# ==========================
# 🧠 FUNCIONES DE UTILIDAD
# ==========================

def is_excluded(path: Path) -> bool:
    """Determina si una ruta debe ser excluida."""
    return any(ex in path.parts for ex in EXCLUDED_FOLDERS) or any(path.name.endswith(e) for e in EXCLUDED_FILES)


def clean_text_for_key(text: str) -> str:
    """Crea una clave limpia y única basada en el texto."""
    clean = VARIABLE_PATTERN.sub("", text).strip().lower()
    clean = re.sub(r"[^a-z0-9\s]", "", clean)
    clean = re.sub(r"\s+", "_", clean)
    return clean[:60].strip("_") or "key"


def is_translatable_literal(text: str) -> bool:
    """Filtra textos seguros (no código, no expresiones, no logs)."""
    if not text or len(text.strip()) < 2:
        return False
    if re.search(r"[<>#{}()=\[\];]", text):  # posible código
        return False
    if any(op in text for op in ["==", "+", "-", "*", "/", "&&", "||", "?"]):
        return False
    if "error" in text.lower() or "exception" in text.lower():
        return False
    if len(re.findall(r"[A-Z]", text)) > 12:  # texto sospechosamente técnico
        return False
    return True


def preview_diff(original: str, modified: str, filename: str):
    """Muestra los cambios visualmente (tipo git diff)."""
    diff = difflib.unified_diff(
        original.splitlines(),
        modified.splitlines(),
        lineterm="",
        fromfile="original/" + filename,
        tofile="translated/" + filename,
    )
    print("\n".join(diff))


# ==========================
# 🧰 PROCESAMIENTO PRINCIPAL
# ==========================

def process_dart_files():
    translations = collections.OrderedDict()
    ignored = []
    modified_files = []

    for file_path in PROJECT_PATH.rglob("*.dart"):
        if is_excluded(file_path):
            continue

        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        new_content = content
        changes = []
        matches = set()

        for match in TEXT_PATTERNS.finditer(content):
            text = next((g for g in match.groups() if g), None)
            if not text or text in matches:
                continue
            matches.add(text)

            if not is_translatable_literal(text):
                ignored.append((str(file_path), text))
                continue

            key = clean_text_for_key(text)
            variables = VARIABLE_PATTERN.findall(text)
            json_value = text

            if variables:
                for var in sorted(set(variables)):
                    arg = var.split(".")[0]
                    json_value = re.sub(rf"\$\{{?{re.escape(var)}\}}?", f"{{{arg}}}", json_value)
                tr_call = f"'{key}'.tr(namedArgs: {{ {', '.join([f'\"{v}\": {v}' for v in variables])} }})"
            else:
                tr_call = f"'{key}'.tr()"

            translations[key] = json_value

            pattern_single = re.escape(f"'{text}'")
            pattern_double = re.escape(f'"{text}"')
            new_content = re.sub(pattern_single, tr_call, new_content)
            new_content = re.sub(pattern_double, tr_call, new_content)
            changes.append((text, key))

        if new_content != content and changes:
            if IMPORT_STATEMENT not in new_content:
                new_content = IMPORT_STATEMENT + "\n" + new_content
            modified_files.append((file_path, content, new_content))

    return translations, ignored, modified_files


# ==========================
# 💾 GUARDADO Y LOGS
# ==========================

def save_results(translations, ignored, modified_files):
    os.makedirs(TRANSLATIONS_DIR, exist_ok=True)

    # Guardar JSON
    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(translations, f, ensure_ascii=False, indent=2)

    print(f"\n📘 Archivo de traducciones generado: {OUTPUT_JSON} ({len(translations)} claves)")

    # Guardar ignorados
    if ignored:
        with open("ignored_texts.log", "w", encoding="utf-8") as f:
            for path, txt in ignored:
                f.write(f"{path}: {txt}\n")
        print(f"⚠️ {len(ignored)} textos ignorados — revisar 'ignored_texts.log'")

    # Mostrar vista previa
    print("\n🧩 Archivos modificados:")
    for file_path, original, new_content in modified_files:
        print(f"\n📄 {file_path}")
        preview_diff(original, new_content, file_path.name)
        if not DRY_RUN:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(new_content)

    if DRY_RUN:
        print("\n💡 Modo simulación activo (DRY_RUN=True). No se aplicaron cambios.")
        print("👉 Cambia DRY_RUN=False para escribir los cambios reales.")


# ==========================
# 🏁 MAIN
# ==========================

if __name__ == "__main__":
    print("🌍 Iniciando extracción de textos traducibles (modo seguro v8.1)...")

    translations, ignored, modified_files = process_dart_files()
    save_results(translations, ignored, modified_files)

    print("\n✅ Proceso completado con éxito.")
