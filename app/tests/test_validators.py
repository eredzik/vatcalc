import pytest
from pydantic import BaseModel

from ..validators import NipNumber, RegonNumber


def test_nip_validation():
    # Valid case
    class TestModel(BaseModel):
        nip: NipNumber

    nip1 = "0000000000"
    assert TestModel(nip=nip1).nip == nip1
    with pytest.raises(ValueError):
        # Too short
        TestModel(nip="123")
        # Good length but not valid
    with pytest.raises(ValueError):
        TestModel(nip="1234567890")

def test_regon_validation():
    # Valid case 9-digit
    class TestModel(BaseModel):
        regon: RegonNumber

    regon1 = "000000000"
    assert TestModel(regon=regon1).regon == regon1
    with pytest.raises(ValueError):
        # Too short
        TestModel(regon="123")
        # Good length but not valid
    with pytest.raises(ValueError):
        TestModel(regon="123456789")
    # Valid case 14-digit
    class TestModel(BaseModel):
        regon: RegonNumber

    regon2 = "00000000000000"
    assert TestModel(regon=regon2).regon == regon2
    with pytest.raises(ValueError):
        # Too short
        TestModel(regon="123")
        # Good length but not valid
    with pytest.raises(ValueError):
        TestModel(regon="12345678901234")
