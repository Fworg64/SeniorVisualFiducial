cmake_minimum_required (VERSION 3.0)
project (oltmans_finder)

find_package (Eigen3 REQUIRED NO_MODULE)
find_package (OpenCV REQUIRED)
add_executable (example src/opencv_ex.cpp)
target_link_libraries (example ${OpenCV_LIBS})
