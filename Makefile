# Makefile for Assimp Model Loader
# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O3 -g
LDFLAGS = 

# Project name and files
TARGET = model_loader
SOURCES = main.cpp model_loader.cpp
OBJECTS = $(SOURCES:.cpp=.o)
HEADERS = model_loader.h

# Libraries
LIBS = -lGL -lGLEW -lglfw -lassimp -lpthread -ldl

# Include paths
INCLUDES = -I/usr/include \
           -I/usr/local/include \
           -I.

# Library paths (add more if needed)
LIB_PATHS = -L/usr/lib \
            -L/usr/local/lib \
            -L/usr/lib/x86_64-linux-gnu

# STB Image configuration
STB_IMAGE_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
CXXFLAGS += -DSTB_IMAGE_IMPLEMENTATION

# Platform-specific settings
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LIBS += -lX11 -lXxf86vm -lXrandr -lpthread -lXi -ldl -lXinerama -lXcursor
endif

# Build rules
.PHONY: all clean download-deps run debug release

# Default target
all: download-deps $(TARGET)

# Download stb_image.h if not present
download-deps:
	@if [ ! -f stb_image.h ]; then \
		echo "Downloading stb_image.h..."; \
		curl -o stb_image.h $(STB_IMAGE_URL) || wget -O stb_image.h $(STB_IMAGE_URL); \
	fi

# Link the executable
$(TARGET): $(OBJECTS)
	@echo "Linking $@..."
	$(CXX) $(OBJECTS) -o $@ $(LIB_PATHS) $(LIBS) $(LDFLAGS)
	@echo "Build complete: $@"

# Compile source files
%.o: %.cpp $(HEADERS)
	@echo "Compiling $<..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Debug build
debug: CXXFLAGS += -DDEBUG -g3 -O0
debug: clean all

# Release build
release: CXXFLAGS += -DNDEBUG -O3 -march=native
release: clean all

# Run the program
run: all
	@if [ -z "$(MODEL)" ]; then \
		echo "Usage: make run MODEL=path/to/model.fbx"; \
		echo "Supported formats: FBX, OBJ, DAE, GLTF, 3DS, STL, etc."; \
	else \
		./$(TARGET) $(MODEL); \
	fi

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -f $(OBJECTS) $(TARGET)
	@echo "Clean complete"

# Install dependencies (Ubuntu/Debian)
install-deps:
	@echo "Installing dependencies..."
	sudo apt update
	sudo apt install -y build-essential libglew-dev libglfw3-dev \
	                    libglm-dev libassimp-dev libx11-dev \
	                    libxxf86vm-dev libxrandr-dev libxi-dev \
	                    libxinerama-dev libxcursor-dev
	@echo "Dependencies installed"

# Install dependencies (Fedora/RHEL)
install-deps-fedora:
	@echo "Installing dependencies..."
	sudo dnf install -y gcc-c++ make glew-devel glfw-devel \
	                    glm-devel assimp-devel libX11-devel \
	                    libXxf86vm-devel libXrandr-devel libXi-devel \
	                    libXinerama-devel libXcursor-devel
	@echo "Dependencies installed"

# Install dependencies (Arch Linux)
install-deps-arch:
	@echo "Installing dependencies..."
	sudo pacman -S --needed base-devel glew glfw-x11 glm assimp
	@echo "Dependencies installed"

# Help target
help:
	@echo "Assimp Model Loader Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all             - Build the model loader (default)"
	@echo "  clean           - Remove build files"
	@echo "  debug           - Build with debug symbols"
	@echo "  release         - Build with optimizations"
	@echo "  run             - Run the program (use MODEL=path/to/model)"
	@echo "  install-deps    - Install dependencies (Ubuntu/Debian)"
	@echo "  install-deps-fedora - Install dependencies (Fedora/RHEL)"
	@echo "  install-deps-arch   - Install dependencies (Arch Linux)"
	@echo "  help            - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make"
	@echo "  make debug"
	@echo "  make run MODEL=models/test.fbx"
	@echo "  make clean"
	@echo ""
	@echo "Supported model formats:"
	@echo "  FBX, OBJ, DAE/Collada, GLTF/GLB, 3DS, STL, PLY, X, MD2/MD3/MD5,"
	@echo "  ASE, HMP, SMD, VTA, MDL, BLEND, and 40+ more formats"

# Print configuration
info:
	@echo "Configuration:"
	@echo "  Compiler: $(CXX)"
	@echo "  Flags: $(CXXFLAGS)"
	@echo "  Libraries: $(LIBS)"
	@echo "  Target: $(TARGET)"
	@echo ""
	@echo "Checking for required libraries..."
	@command -v pkg-config >/dev/null 2>&1 || echo "Warning: pkg-config not found"
	@pkg-config --exists glew && echo "  ✓ GLEW found" || echo "  ✗ GLEW not found"
	@pkg-config --exists glfw3 && echo "  ✓ GLFW3 found" || echo "  ✗ GLFW3 not found"
	@pkg-config --exists assimp && echo "  ✓ Assimp found" || echo "  ✗ Assimp not found"
	@[ -f /usr/include/glm/glm.hpp ] && echo "  ✓ GLM found" || echo "  ✗ GLM not found"

# Check dependencies before building
check-deps:
	@echo "Checking dependencies..."
	@command -v $(CXX) >/dev/null 2>&1 || { echo "Error: $(CXX) not found"; exit 1; }
	@pkg-config --exists glew || { echo "Error: GLEW not found. Run 'make install-deps'"; exit 1; }
	@pkg-config --exists glfw3 || { echo "Error: GLFW3 not found. Run 'make install-deps'"; exit 1; }
	@pkg-config --exists assimp || { echo "Error: Assimp not found. Run 'make install-deps'"; exit 1; }
	@[ -f /usr/include/glm/glm.hpp ] || { echo "Error: GLM not found. Run 'make install-deps'"; exit 1; }
	@echo "All dependencies found!"

# Automatic dependency generation
depend: $(SOURCES)
	@echo "Generating dependencies..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -MM $(SOURCES) > .depend

-include .depend

# Test with sample model
test: all
	@echo "Running test..."
	@if [ -f "test/cube.obj" ]; then \
		./$(TARGET) test/cube.obj; \
	else \
		echo "No test model found. Create test/cube.obj or run with MODEL=path"; \
	fi

# Create a simple test model (OBJ cube)
create-test-model:
	@mkdir -p test
	@echo "Creating test cube.obj..."
	@echo "# Simple Cube" > test/cube.obj
	@echo "v -1.0 -1.0  1.0" >> test/cube.obj
	@echo "v  1.0 -1.0  1.0" >> test/cube.obj
	@echo "v -1.0  1.0  1.0" >> test/cube.obj
	@echo "v  1.0  1.0  1.0" >> test/cube.obj
	@echo "v -1.0  1.0 -1.0" >> test/cube.obj
	@echo "v  1.0  1.0 -1.0" >> test/cube.obj
	@echo "v -1.0 -1.0 -1.0" >> test/cube.obj
	@echo "v  1.0 -1.0 -1.0" >> test/cube.obj
	@echo "" >> test/cube.obj
	@echo "vn  0.0  0.0  1.0" >> test/cube.obj
	@echo "vn  0.0  1.0  0.0" >> test/cube.obj
	@echo "vn  0.0  0.0 -1.0" >> test/cube.obj
	@echo "vn  0.0 -1.0  0.0" >> test/cube.obj
	@echo "vn  1.0  0.0  0.0" >> test/cube.obj
	@echo "vn -1.0  0.0  0.0" >> test/cube.obj
	@echo "" >> test/cube.obj
	@echo "f 1//1 2//1 4//1 3//1" >> test/cube.obj
	@echo "f 3//2 4//2 6//2 5//2" >> test/cube.obj
	@echo "f 5//3 6//3 8//3 7//3" >> test/cube.obj
	@echo "f 7//4 8//4 2//4 1//4" >> test/cube.obj
	@echo "f 2//5 8//5 6//5 4//5" >> test/cube.obj
	@echo "f 7//6 1//6 3//6 5//6" >> test/cube.obj
	@echo "Test cube created: test/cube.obj"

# Package for distribution
dist: clean
	@echo "Creating distribution package..."
	mkdir -p model_loader_dist
	cp $(SOURCES) $(HEADERS) Makefile README.md model_loader_dist/
	tar -czf model_loader_dist.tar.gz model_loader_dist
	rm -rf model_loader_dist
	@echo "Distribution package created: model_loader_dist.tar.gz"

# Static analysis
analyze:
	@echo "Running static analysis..."
	@command -v cppcheck >/dev/null 2>&1 || { echo "cppcheck not found, skipping..."; exit 0; }
	cppcheck --enable=all --suppress=missingIncludeSystem $(SOURCES) $(HEADERS)

# Format code
format:
	@echo "Formatting code..."
	@command -v clang-format >/dev/null 2>&1 || { echo "clang-format not found, skipping..."; exit 0; }
	clang-format -i $(SOURCES) $(HEADERS)

# Count lines of code
count:
	@echo "Lines of code:"
	@wc -l $(SOURCES) $(HEADERS) Makefile | sort -n


	# Format code
bonjour:
	@echo "yoyoy code..."
	rm -R ./stb_image.h
	rm -R ./main.o 
	rm -R ./model_loader.o
	
	