# Makefile

# Define variables
INPUT_FILE = how_to_build_a_time_machine.md
OUTPUT_FILE = git.html
RESOURCE_PATH = img

# Default target
all: $(OUTPUT_FILE)

# Rule to generate the HTML output
$(OUTPUT_FILE): $(INPUT_FILE) 
	pandoc -i -t slidy -s $< -o $@ --self-contained --resource-path=$(RESOURCE_PATH)

# Clean target to remove the generated file
clean:
	rm -f $(OUTPUT_FILE)

# Phony targets
.PHONY: all clean
