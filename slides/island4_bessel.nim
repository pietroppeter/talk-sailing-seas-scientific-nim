# The C function of slide 5.2 (slides/island4_interop.nim), declared here:
# an importc proc declared inside the deck's templates is reported as a redefinition.
proc j0*(x: cdouble): cdouble {.importc, header: "<math.h>".}
