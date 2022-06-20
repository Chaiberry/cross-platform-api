%module pySample

%include "stdint.i"
%include "std_vector.i"
%include "std_string.i"
%include "std_pair.i"
%include "pybuffer.i"

%pybuffer_mutable_binary(char* buffer, size_t buffer_size);

// Add necessary symbols to generated header
%{
#include <sample.hpp>
%}

// Process symbols in header
%include "sample.hpp"
