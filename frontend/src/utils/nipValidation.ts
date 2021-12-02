import * as yup from 'yup';
export default function validateNip(nipNumber: string): boolean {

    if (nipNumber.length !== 10) {
        return false
    } else {
        const weights: number[] = [6, 5, 7, 2, 3, 4, 5, 6, 7]
        const control_sum = weights
            .map((elem, index) => elem * Number(nipNumber[index]))
            .reduce((prev, current) => (prev + current), 0)
            % 11
        if (control_sum !== Number(nipNumber[9])) {
            return false
        } else {
            return true
        }
    }
}

export const nipNumberYup = (
    yup
        .string()
        .matches(
            /[0-9-]*/
        )
        .test("nipValidation",
            "Niepoprawny numer NIP",
            (val) => val ? validateNip(val) : false)
);