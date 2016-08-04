set VS90COMNTOOLS=%VS110COMNTOOLS%
python buildPyGrape.py build_ext --inplace || exit 1
@pause