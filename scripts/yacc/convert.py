import re

def convert_yacc_to_markdown(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        in_rules = False
        current_rule = ""

        outfile.write("# Lojban Grammar\n\n")

        for line in infile:
            # Retain comments
            if line.strip().startswith('/*') or line.strip().startswith('//'):
                outfile.write(f"> {line.strip()}\n\n")
                continue

            # Check if we're in the rules section
            if line.strip() == '%%':
                in_rules = not in_rules
                if in_rules:
                    outfile.write("## Grammar Rules\n\n")
                continue

            if in_rules:
                # Remove trailing whitespace and newline
                line = line.rstrip()

                # Start of a new rule
                if line and not line.startswith(' ') and not line.startswith('\t'):
                    if current_rule:
                        outfile.write(current_rule + "\n```\n\n")
                    rule_name = line.split(':')[0].strip()
                    current_rule = f"### {rule_name}\n\n```bnf\n{line}"
                # Continuation of current rule
                elif line:
                    # Replace '|' with indented new line
                    if line.strip().startswith('|'):
                        current_rule += '\n    ' + line.strip()
                    else:
                        current_rule += ' ' + line.strip()
            else:
                # Write non-rule lines as code blocks
                if line.strip():
                    outfile.write(f"```\n{line.strip()}\n```\n\n")

        # Write the last rule if there is one
        if current_rule:
            outfile.write(current_rule + "\n```\n\n")

# Usage
input_file = 'lojban_grammar.y'
output_file = 'lojban_grammar.md'
convert_yacc_to_markdown(input_file, output_file)
print(f"Conversion complete. Output saved to {output_file}")