# -*- coding: utf-8 -*-
from openai import OpenAI

base_url = "https://api.openai-sb.com/v1"

client = OpenAI(
    # This is the default and can be omitted
    api_key="",
    base_url=base_url
)

def translate(text, source_language, target_language):
    prompt = f"你是iOS本地化大师，请将以下``中的文本，从{source_language}翻译成语言代码是{target_language}的本地化文案：\n`{text}`"
    completion = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "system",
                "content": prompt,
            },
            {
                "role": "user",
                "content": text
            },
        ],
        temperature=0
    )
    return completion.choices[0].message.content.strip()

def translate_localizable_strings(text, source_language, target_language):
    prompt = f"将以下localizable.strings文件的文案翻译成{target_language}语言代码的语言，请注意遵循本土化的语言习惯，但要保持原有格式（\"key\"=\"value\";）不变："
    
    # 计算text行数
    lines = text.splitlines()
    line_count = len(lines)
    print("\n========================")
    print(f"\ntranslating {line_count} lines from {source_language} to {target_language}, {prompt}:\n")
    print(text)
    
    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": prompt,
            },
            {
                "role": "user",
                "content": text
            },
        ],
        temperature=0
    )
    
    result = completion.choices[0].message.content.strip()
    
    print("---------------------------")
    line_count = len(result.splitlines())
    print(f"\ntranslated {line_count} line:\n")
    print(result)
    print("\n========================")

    return result

def test_translate():
    # 示例用法
    source_text = "Hello, how are you? this is paste queue"
    translated_text = translate(source_text, "english", "zh-tw")
    print(translated_text)

def test_translate_localizable_strings():
    # 示例用法
    source_text = """
    "quickmenu_option_switch" = "Switch Item ⌘[0-9]";
"quickmenu_option_search" = "Search ⌘F";
"quickmenu_option_switchTab" = "Switch List ⌘;";
"quickmenu_option_copy" = "Copy to Clipboard ⌘C";
"quickmenu_option_star" = "Bookmark ⌘S";
    """
    translated_text = translate_localizable_strings(source_text, "en", "zh-tw")
    print(translated_text)
    
def test_translate_localizable_strings2():
    # 示例用法
    source_text = """"post_action_text" = "Text";
"post_action_text_content" = "Text Added at the End";
"pin_context_split_to_multilines" = "Split into Multiple Items";
"pin_context_paste_as" = "Paste as...";
"pin_context_edit" = "Edit";
"pin_lists_shortcut" = "在快捷窗口中打开：";
"pin_lists_shortcut_for_pin" = "在主窗口中打开：";
"quickmenu_option_show_when_cmd_down" = "Auto Display on ⌘ Down";
"quickmenu_general_preview_on_hover_delay" = "Preview Delay";
"quickmenu_general_move_to_top" = "Move to Top after Use";
"settings_general" = "General";
"settings_shortcuts" = "Shortcuts";
"settings_paste_format" = "Paste Format";
"settings_lists" = "Lists";
"settings_quick_menu" = "Quick Menu";
"settings_main_window" = "Main Window";
"settings_paste_stack" = "Paste Queue";
"settings_ignore" = "Ignore";
"settings_ocr" = "OCR";
"settings_about" = "About";
"settings_appupdates" = "Software Update Available";
"settings_license" = "License";
"upgrade_to_recommand_os_version" = "推荐使用 macOS 13.0+ 以获得最佳体验!";
"sounds_selection" = "选择声音";
"shortcuts" = "快捷键";"""
    translated_text = translate_localizable_strings(source_text, "english", "zh-tw")
    
def test_translate_localizable_strings_sk():
    # 示例用法
    source_text = """"post_action_text" = "Text";
"post_action_text_content" = "Text Added at the End";
"pin_context_split_to_multilines" = "Split into Multiple Items";
"pin_context_paste_as" = "Paste as...";
"pin_context_edit" = "Edit";
"pin_lists_shortcut" = "在快捷窗口中打开：";
"pin_lists_shortcut_for_pin" = "在主窗口中打开：";
"quickmenu_option_show_when_cmd_down" = "Auto Display on ⌘ Down";
"quickmenu_general_preview_on_hover_delay" = "Preview Delay";
"quickmenu_general_move_to_top" = "Move to Top after Use";
"settings_general" = "General";
"settings_shortcuts" = "Shortcuts";
"settings_paste_format" = "Paste Format";
"settings_lists" = "Lists";
"settings_quick_menu" = "Quick Menu";
"settings_main_window" = "Main Window";
"settings_paste_stack" = "Paste Queue";
"settings_ignore" = "Ignore";
"settings_ocr" = "OCR";
"settings_about" = "About";
"settings_appupdates" = "Software Update Available";
"settings_license" = "License";
"upgrade_to_recommand_os_version" = "推荐使用 macOS 13.0+ 以获得最佳体验!";
"sounds_selection" = "选择声音";
"shortcuts" = "快捷键";
"appearance" = "主题";
"appearance_light" = "Light";
"appearance_dark" = "Dark";
"appearance_auto" = "System";
"popup_at_fallback" = "由于系统限制，在一些应用中无法正确定位输入位置，请为之选择一项备选位置";
"main_window_auto_collapse" = "Auto Collapse";
"main_window_full_mode" = "Full Height";
"paste_stack_order" = "Default Order:";
"paste_stack_order_stack" = "Stack Order";
"paste_stack_order_queue" = "Queue Order";
"paste_stack_order_shuffle" = "Shuffle Order";
"ignore_apps" = "忽略的应用程序";
"acknowledgements" = "Acknowledgements";
"visit_website" = "Visite Website";
"contact_us" = "Contact Us";
"copyright" = "©️Copyright";
"lists_desc" = "通过收集列表、智能列表更好地组织你的内容";
"lists_name" = "名字";
"is_smartlist" = "智能列表";
"count" = "数量";
"desc" = "智能列表描述";
"name" = "功能";
"shortcuts_quick_menu" = "开关快捷菜单";
"shortcuts_main_window" = "开关主窗口";
"shortcuts_paste_stack" = "开关粘贴队列";"""
    translated_text = translate_localizable_strings(source_text, "english", "sk")
    
def main():
    parser = argparse.ArgumentParser(description='Process some arguments.')
    parser.add_argument('--api_key', nargs='?', const='', help='Translation provider key')
    apikey = args.api_key
    if apikey:
        openaiapi.client.api_key = apikey

    test_translate_localizable_strings_sk()
    
if __name__ == "__main__":
    main()
