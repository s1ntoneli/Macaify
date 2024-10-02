import os
import git
#from googletrans import Translator
import argparse
import openaiapi

lang_codes = {
    'zh-Hans': 'zh-cn',
    'zh-Hant': 'zh-tw',
    'en': 'en'
}

def translate_strings(strings, target_lang, provider):
#    translator = Translator()
    translations = {}
    print(f"===========\ntranslating from en to {target_lang}")
    for key, en_string in strings.items():
        if provider == "openai":
            translation = openaiapi.translate(en_string, "english", target_lang)
        else:
            translation = openaiapi.translate(en_string, "english", target_lang)
#            translation = translator.translate(en_string, dest=target_lang).text
        translations[key] = translation
    return translations

def write_translations(base_file_path, file_path, base_strings, target_strings, translations):
    print(f"===========\nwriting to file: {file_path}, {len(base_strings)}/{len(translations)}")
    
    with open(base_file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    with open(file_path, 'w', encoding='utf-8') as file:
        for line in lines:
            line = line.strip()
            if line.startswith('/*') or line.startswith('//') or line == '':
                file.write(line + '\n')
            elif '=' in line:
                key, value = line.split('=', 1)
                key = key.strip().strip('"')
                if key in translations:
                    file.write(f'"{key}" = "{translations[key]}";')
                    print(f'writing translated "{key}" = "{translations[key]}";')
                elif key in target_strings:
                    file.write(f'"{key}" = "{target_strings[key]}";')
                file.write('\n')

def find_localizable_files(root_dir):
    localizable_files = {}
    print(f"Searching for localization files in: {root_dir}")
    for dirpath, dirnames, filenames in os.walk(root_dir):
        print(dirpath)
        if dirpath.endswith('.lproj'):
            lang = os.path.basename(dirpath).split('.')[0]
            for filename in filenames:
                if filename == 'Localizable.strings':
                    file_path = os.path.join(dirpath, filename)
                    localizable_files[lang] = file_path
                    print(f"Added {lang} localization file: {file_path}")
    print(f"Total localization files found: {len(localizable_files)}")
    return localizable_files

def parse_strings_file(file_path):
    strings = {}
    print(f"Parsing file: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            if '=' in line:
                key, value = line.split('=', 1)
                key = key.strip().strip('"')
                value = value.strip().strip(';').strip('"')
                strings[key] = value
    print(f"Parsed {len(strings)} strings from the file")
    return strings

def find_missing_strings(base_strings, target_strings):
    missing = {k: v for k, v in base_strings.items() if k not in target_strings}
    print(f"Found {len(missing)} missing strings")
    return missing
    
def parse_strings_lines_to_strings(lines):
    strings = {}
    for line in lines:
        if '=' in line:
            key, value = line.split('=', 1)
            key = key.strip().strip('"')
            value = value.strip().strip(';').strip('"')
            strings[key] = value
    return strings
    
def translate_and_write(base_file_path, base_strings_new, base_lang, mapped_lang, file_path, additional_strings, provider):
    print(f"\nProcessing {mapped_lang} localization")
    target_strings = parse_strings_file(file_path)
    missing_strings = find_missing_strings(base_strings_new, target_strings)
    strings_to_translate = {**missing_strings, **additional_strings}

    if strings_to_translate:
        print(f"\nStrings to translate for {mapped_lang}:")
        for key, value in strings_to_translate.items():
            print(f'"{key}" = "{value}";')

        all_translated_lines = []
        # 每 50 项合并翻译一次
        # strings_to_translate 数组 join 成长字符串
        strings_list = list(strings_to_translate.items())
        for i in range(0, len(strings_list), 50):
            to_be_translated_lines = "\n".join([f'"{key}" = "{value}";' for key, value in strings_list[i:i+50]])
            translated_lines = openaiapi.translate_localizable_strings(to_be_translated_lines, "english", mapped_lang)

            all_translated_lines.extend(translated_lines.splitlines())

#        print(f"\nTranslated lines for {mapped_lang}:")
#        for line in all_translated_lines:
#            print(line)
        print(f"\nall_translated_lines: {len(all_translated_lines)}")
        translated_strings = parse_strings_lines_to_strings(all_translated_lines)

        print(f"\nTranslated strings for {mapped_lang} {len(translated_strings.items())}:")
#        for key, value in translated_strings.items():
#            print(f'"{key}" = "{value}";')

        write_translations(base_file_path, file_path, base_strings_new, target_strings, translated_strings)
        print(f"Translations written to {file_path}")
    else:
        print(f"No strings to translate for {mapped_lang}")

def autotranslate(old_commit_id, provider, type):
    root_dir = os.path.join(os.getcwd(), "")
    repo = git.Repo(root_dir)

    print(f'Previous value: {old_commit_id}')

    localizable_files = find_localizable_files(root_dir)
    # Find the English file (it could be 'en', 'en-US', 'en-GB', etc.)
    en_key = next((lang for lang in localizable_files.keys() if lang.startswith('en')), None)

    print("Available languages:", ", ".join(localizable_files.keys()))
    
    if not en_key:
        print("Error: English localization file not found.")
        return

    # Checkout the old commit
    if old_commit_id:
        print(f"Checking commit {old_commit_id}, file {localizable_files[en_key]}")
        relative_path = os.path.relpath(localizable_files[en_key], os.getcwd())
        base_contents = getFileContentsInCommit(relative_path, old_commit_id)
        base_strings_old = parse_strings_lines_to_strings(base_contents.splitlines())

    base_strings_new = parse_strings_file(localizable_files[en_key])


    if type == "checken":
        print("=========== check en ===========")
            # Find the diff between the old and new base strings
        if base_strings_old:
            diff_strings = {k: v for k, v in base_strings_new.items() if k in base_strings_old and base_strings_new[k] != base_strings_old[k] or k not in base_strings_old}
            print(f"Found {len(diff_strings)} modified strings in the base language")
        else:
            diff_strings = {}

        translate_and_write(localizable_files[en_key], base_strings_new, "english", 'en', localizable_files[en_key], diff_strings, provider)
    else:
        print("=========== translation ============")
            # Find the diff between the old and new base strings
        if base_strings_old:
            diff_strings = {k: v for k, v in base_strings_new.items() if k in base_strings_old and base_strings_new[k] != base_strings_old[k]}
            print(f"Found {len(diff_strings)} modified strings in the base language")
        else:
            diff_strings = {}

        for lang, file_path in localizable_files.items():
            mapped_lang = lang_codes.get(lang, lang)
            if mapped_lang.startswith('en'):
                continue
            translate_and_write(localizable_files[en_key], base_strings_new, "english", mapped_lang, file_path, diff_strings, provider)
    
def checkCN():
    # 找到 cn
    root_dir = os.path.join(os.getcwd(), "")
    
    # 找到 en
#    translate_and_write(localizable_files[en_key], base_strings_new, mapped_lang, file_path, diff_strings)

def main():
    # 创建一个ArgumentParser对象
    parser = argparse.ArgumentParser(description='Process some arguments.')

    # 添加两个命令行参数
#    parser.add_argument('--prev', type=str, help='The previous value')
#    parser.add_argument('--target', type=str, help='The target value')
    parser.add_argument('--prev', nargs='?', const='', help='The previous value')
    parser.add_argument('--target', nargs='?', const='', help='The target value')

    parser.add_argument('action', nargs='?', const='', help='Pre check CN')
    
    parser.add_argument('--provider', nargs='?', const='', help='Translation provider')
    parser.add_argument('--api_key', nargs='?', const='', help='Translation provider key')
    parser.add_argument('--base_url', nargs='?', const='', help='Translation provider base url')
    
    parser.add_argument('--base_lang', nargs='?', const='', help='The base lang')
    parser.add_argument('--target_lang', nargs='?', const='', help='The target lang')

#    parser.add_argument('checken', nargs='?', const='', help='Check en translation')

    # 解析命令行参数
    args = parser.parse_args()
    
    base = args.base_lang
    target = args.target_lang
    
    apikey = args.api_key
    base_url = args.base_url
    if apikey:
        openaiapi.client.api_key = apikey
        openaiapi.client.base_url = base_url
    
    action = args.action
    if not action:
        action = "translation"
        
    print("------ action is ", action)

    if action == "checkcn":
        checkCN()
    elif base and target:
        translation_from_to(base, target)
    else:
        # 访问参数值
        old_commit_id = args.prev
        
        provider = args.provider
        if not provider:
            provider = "openai"
        
        autotranslate(old_commit_id, provider, action)
    

def translation_from_to(base_lang, target_lang):
#    base_file_path, base_strings_new, mapped_lang, file_path, additional_strings, provider
    root_dir = os.path.join(os.getcwd(), "")
    localizable_files = find_localizable_files(root_dir)
    # Find the English file (it could be 'en', 'en-US', 'en-GB', etc.)
    base_key = next((lang for lang in localizable_files.keys() if lang.startswith(base_lang)), None)
    target_key = next((lang for lang in localizable_files.keys() if lang.startswith(target_lang)), None)
    
    if not base_key:
        print("Error: English localization file not found.")
        print("Available languages:", ", ".join(localizable_files.keys()))
        return
    
    if not target_key:
        print("Error: target localization file not found.")
        print("Available languages:", ", ".join(localizable_files.keys()))
        return
    
    base_strings_new = parse_strings_file(localizable_files[base_key])
    target_lang = lang_codes.get(target_lang, target_lang)
    translate_and_write(localizable_files[base_key], base_strings_new, base_lang, target_lang, localizable_files[target_key], {}, "openai")
    
def getFileContentsInCommit(file_path, commit_id):
    repo = git.Repo(os.getcwd())
    commit = repo.commit(commit_id)
    file_content = commit.tree[file_path].data_stream.read().decode('utf-8')
    return file_content

if __name__ == "__main__":
    main()
