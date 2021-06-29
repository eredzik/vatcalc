def validate_nip(nip: str) -> str:
    if len(nip) != 10:
        raise ValueError("Nip must have exactly 10 characters.")

    weights = [6, 5, 7, 2, 3, 4, 5, 6, 7]
    checksum_calculated = (
        sum([int(nip[i]) * weight for i, weight in enumerate(weights)]) % 11
    )
    if checksum_calculated != int(nip[9]):
        raise ValueError("Nip validation failed. Check nip number.")
    return nip
