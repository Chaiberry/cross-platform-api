set(TGTNAME Sample)

set(SRCS
    sample.cpp)

add_library(${TGTNAME} ${SRCS})

add_library(${PROJECT_NAMESPACE}::Sample ALIAS Sample)
