import dataclasses
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    static_check_init_args = dataclasses.dataclass
else:

    def static_check_init_args(cls):
        return cls


class NipNumber(str):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, nip: str) -> str:
        if len(nip) != 10:
            raise ValueError("Nip must have exactly 10 characters.")

        weights = [6, 5, 7, 2, 3, 4, 5, 6, 7]
        checksum_calculated = (
            sum([int(nip[i]) * weight for i, weight in enumerate(weights)]) % 11
        )
        if checksum_calculated != int(nip[9]):
            raise ValueError("Nip failed checksum validation")
        return cls(nip)
