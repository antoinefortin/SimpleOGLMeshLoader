# SimpleOGLMeshLoader
Just a simple fbx, gltf and so on loader and viewer in c++ for Linux 


# Build 
make # build
make bonjour # fresh reset


# Test it
/model_loader ./test/icosphere.fbx 

# Create the obj file 
make create-test-model


# Build 
make
make debug
make release
make clean
make run MODEL=path/to/model.fbx


# test 

make create-test-model
make test
