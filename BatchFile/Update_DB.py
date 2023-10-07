import sys
import chardet
import glob
import re

def main():
    if len(sys.argv) != 2:
        print("Usage: python update_settings.py <new_value>")
        sys.exit(1)

    # Define the new value for 'NAME'
    new_value = str(sys.argv[1])
    file_path = glob.glob('../Django_server/asset_management/asset_management/*',recursive= True)
    print(file_path)
    file_path = glob.glob('../Django_server/asset_management/asset_management/settings.py')[0]

    rawdata = open(file_path, 'rb').read()
    result = chardet.detect(rawdata)
    charenc = result['encoding']

    # Read the file content
    with open(file_path, 'r', encoding=charenc) as file:
        content = file.read()


    # Use regular expressions to find and replace 'NAME' within the 'default' dictionary
    # pattern = r"('default':\s*\{[^}]*'NAME':\s*)'[^']*'([^}]*\})"  # Matches 'NAME' within the 'default' dictionary
    pattern = r"('default':\s*\{[^}]*'NAME':\s*)'[^']*'([^}]*\})"  # Matches 'NAME' within the 'default' dictionary
    replacement = r"\1'{}'\2".format(new_value)  # Replace 'NAME' with the new value
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)

    # Open the file in write mode to overwrite its content with the modified data
    with open(file_path, 'w') as file:
        file.write(content)
    
if __name__ == "__main__":
    main()