import pytest

from ..validators import validate_nip


def test_nip_validation():
    # Valid case
    nip1 = "0000000000"
    assert validate_nip(nip1) == nip1
    with pytest.raises(ValueError):
        # Too short
        validate_nip("123")
        # Good length but not valid
    with pytest.raises(ValueError):
        validate_nip("1234567890")
