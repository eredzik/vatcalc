import { useFormik } from "formik";
import { useEffect } from "react";
import { Button, Divider, Form, Message } from "semantic-ui-react";
import * as yup from 'yup';
import { Layout } from "../../components/Layout";
import { useREGONQueryByNIP } from "../../hooks/enterpriseApi";
import { useTradingPartnersAdd } from "../../hooks/partnersApi";
import { useUser } from "../../hooks/userApi";
import { nipNumberYup } from "../../utils/nipValidation";

export default function AddTradingPartner() {
    const add_partner = useTradingPartnersAdd()
    const user = useUser()
    const formik = useFormik({
        initialValues: {
            nipNumber: "",
            regonNumber: "",
            fullName: "",
            shortName: "",
            country: "",
            postalCode: "",
            city: "",
            streetName: "",
            buildingNumber: "",
            flatNumber: "",
            bankAccountNumber: "",
            email: "",
            phoneNumber: ""
        },
        validationSchema: yup.object({
            nipNumber: nipNumberYup,
        }),
        onSubmit: ((v) => {

            console.log("submitted"); add_partner.mutate({
                address: v.postalCode,
                enterprise_id: user.data?.data.fav_enterprise_id || -1,
                name: v.fullName,
                nip_number: v.nipNumber
            })

        })
    })
    console.log(add_partner.isError)
    const { isSuccess, data, ...data_partner } = useREGONQueryByNIP(formik.values.nipNumber)
    useEffect(() => {
        if (isSuccess && data !== undefined) {
            formik.setFieldValue("fullName", data.company_name || "")
            formik.setFieldValue("shortName", data.company_name.substr(0, 20) || "")
            formik.setFieldValue("postalCode", data.postal_code || "")
            formik.setFieldValue("city", data.city || "")
            formik.setFieldValue("streetName", data.street || "")
            formik.setFieldValue("buildingNumber", data.house_no || "")
            formik.setFieldValue("flatNumber", data.suite_no || "")
        }
    }, [isSuccess, formik, data])
    const parse_error_code = (error_code: string) => {
        if (error_code === '4') {
            return "Nie znaleziono firmy o podanym numerze NIP."
        }
        return "Nieznany błąd."
    }

    return (
        <Layout>
            <Form
                onSubmit={formik.handleSubmit} e
                error={add_partner.isError}
                success={add_partner.isSuccess}>
                <Divider horizontal>Dane podstawowe</Divider>

                <Form.Group widths="4">
                    <Form.Input
                        label="Podaj numer NIP"
                        placeholder="Numer NIP"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        error={formik.errors.nipNumber ||
                            (data_partner.error?.error_code
                                ? parse_error_code(data_partner.error?.error_code) : null)}
                        required
                        id="nipNumber" />
                    <Form.Input
                        label="Numer REGON"
                        id="regonNumber"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.regonNumber} />
                </Form.Group>
                <Form.Button
                    primary
                    children={"Pobierz dane"}
                    disabled={!!formik.errors.nipNumber}
                    loading={data_partner.isLoading}
                    onClick={() => data_partner.refetch()}
                    type="button" />
                <Form.Group widths="2" style={{ display: "flex", flexDirection: "column" }}>
                    <Form.Input
                        label="Nazwa firmy"
                        required
                        id="fullName"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.fullName} />
                    <Form.Input
                        label="Nazwa skrócona"
                        id="shortName"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.shortName} />
                </Form.Group>
                <Divider horizontal>Dane adresowe</Divider>
                <Form.Group label="dupa" labelInfo="abcd" style={{ display: "flex", flexWrap: "wrap" }}>
                    <Form.Input
                        label="Kraj"
                        required
                        id="country"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.country} />
                    <Form.Input
                        label="Kod pocztowy"
                        required
                        id="postalCode"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.postalCode} />
                    <Form.Input
                        label="Miasto"
                        required
                        id="city"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.city} />
                    <Form.Input
                        label="Ulica"
                        required
                        id="streetName"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.streetName} />
                    <Form.Input
                        label="Numer budynku"
                        id="buildingNumber"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.buildingNumber} />
                    <Form.Input
                        label="Nr lokalu"
                        id="flatNumber"
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        value={formik.values.flatNumber} />
                </Form.Group>
                <Divider horizontal>Dane inne</Divider>

                <Form.Group>
                    <Form.Input label="Rachunek bankowy" />
                    <Form.Input label="E-mail" />
                    <Form.Input label="Numer telefonu" />
                </Form.Group>

                <Button
                    primary
                    loading={add_partner.isLoading}
                    disabled={add_partner.isLoading}
                    children="Dodaj kontrahenta"
                />
                <Message
                    error
                    header="Błąd!"
                    content="Kontrahent o podanym numerze nip już istnieje." />
                <Message
                    success
                    header="Dodano!"
                    content="Kontrahent został dodany! " />
            </Form>
        </Layout>);
}

