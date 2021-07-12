import pytest
from pydantic import BaseModel

from ..validators import NipNumber


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
