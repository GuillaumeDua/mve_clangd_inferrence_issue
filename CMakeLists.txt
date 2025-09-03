cmake_minimum_required(VERSION 3.25)

project(GOOD)

add_executable(BAD_INFERRENCE ${CMAKE_CURRENT_SOURCE_DIR}/BAD_INFERRENCE.cpp)

add_executable(${PROJECT_NAME}
    ${CMAKE_CURRENT_SOURCE_DIR}/source.cpp
)
target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

