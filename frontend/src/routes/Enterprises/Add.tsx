import {
  // CircularProgress,
  // Container,
  FormControl,
  FormHelperText,
  Grid,
  MenuItem,
  MobileStepper,
  Select,
  TextField,
  Typography
} from "@material-ui/core";
import { useFormik } from "formik";
import { Dispatch, SetStateAction, useState } from "react";
import { Redirect } from "react-router-dom";
import { Button, Form, Header } from "semantic-ui-react";
import * as yup from 'yup';
import { Layout } from "../../components/Layout";
// import { ButtonWithLoading } from "../../components/LoadingButton";
import { useEnterpriseMutation } from "../../hooks/enterpriseApi";
import { nipNumberYup } from "../../utils/nipValidation";

const steps = [
  'Dodaj swoją jednoosobową działalność gospodarczą',
  'Uzupełnij brakujące dane',
  "Wybierz aktualną formę opodatkowania",
  "ktos"]
export default function EnterpriseAdd() {
  const [nipNumber, setNipNumber] = useState<string>("");
  const [activeStep, setActiveStep] = useState(0);
  const nextPageHandler = () => setActiveStep(activeStep + 1);
  const prevPageHandler = () => setActiveStep(activeStep - 1);
  return (
    <Layout>
      <MobileStepper
        variant="dots"
        steps={steps.length}
        activeStep={activeStep}
        backButton={<div />}
        nextButton={<div />} />
      {
        (activeStep === 0) &&
        <Page0
          sendNipNumber={setNipNumber}
          nextPageHandler={nextPageHandler} />
      }
      {
        (activeStep === 1) &&
        <Page1
          inputNipNumber={nipNumber}
          prevPageHandler={prevPageHandler} />
      }



    </Layout >
  );
}

interface Page0Props {
  sendNipNumber: Dispatch<SetStateAction<string>>
  nextPageHandler: () => void
}
function Page0({ sendNipNumber, nextPageHandler }: Page0Props) {

  const formik = useFormik({
    initialValues: {
      nipNumber: ""
    },
    validationSchema: yup.object({
      nipNumber: nipNumberYup
    }),
    onSubmit: (values) => {
      sendNipNumber(values.nipNumber);
      nextPageHandler();
    }, validateOnMount: true
  });
  const [isLoading, setIsLoading] = useState(false);
  return (

    <Form onSubmit={formik.handleSubmit}>

      <Header variant="h4" >{steps[0]}</Header>



      Najpierw wpisz numer nip swojej firmy -
      pobierzemy wszystkie możliwe informacje z bazy REGON.
      Możesz też wpisać dane ręcznie.

      <Form.Input label="Numer NIP" required fullWidth variant="outlined"
        type="text"
        margin="normal"
        id='nipNumber'
        error={formik.touched.nipNumber && Boolean(formik.errors.nipNumber)}
        onChange={e => { console.log(formik.touched.nipNumber); formik.handleChange(e) }}
        value={formik.values.nipNumber}
        helperText={formik.touched.nipNumber && formik.errors.nipNumber}
        onBlur={formik.handleBlur}
      />
      <Form.Button
        type="button"
        primary
        disabled={Boolean(formik.errors.nipNumber)}
        onClick={() => {
          formik.handleSubmit()
          setIsLoading(true);
          sendNipNumber(formik.values.nipNumber);
          nextPageHandler();
        }}
        loading={isLoading}
        content="Pobierz dane" />
      {/* {isLoading ? <CircularProgress color="secondary" size={24} /> : "Pobierz dane"} */}

      lub
      <Grid item justify="center">
        <Button
          type="button"
          primary
          onClick={nextPageHandler}>
          Wpisz ręcznie
        </Button>
      </Grid>
    </Form>

  )
}
interface Page1Props {
  inputNipNumber: string
  prevPageHandler: () => void

}
function Page1({ inputNipNumber, prevPageHandler }: Page1Props) {
  const enterpriseAdd = useEnterpriseMutation()
  const formik = useFormik({
    initialValues: {
      nipNumber: inputNipNumber,
      address: "",
      name: "",
      taxSchema: "",
    }, validationSchema: yup.object({
      nipNumber: nipNumberYup,
      address: yup.string().test(
        'nonempty',
        "Adres nie może być pusty",
        val => val ? true : false),
      name: yup.string().test(
        'nonempty',
        "Nazwa nie może być pusta",
        val => val ? true : false),
      taxSchema: yup.string().test('unselected',
        "Wybierz formę opodatkowania",
        val => { console.log(val); return val ? true : false })
    }),
    onSubmit: (values) => {
      enterpriseAdd.mutate({
        address: formik.values.address,
        name: formik.values.name,
        nip_number: formik.values.nipNumber,
      })
    },
    validateOnMount: true
  });

  return (
    <form onSubmit={formik.handleSubmit}>
      <Grid container alignItems="center" direction="column" spacing={1}>

        <Grid item>
          <Typography variant="h4">
            {steps[1]}
          </Typography>
        </Grid>
        <Grid>
          <TextField label="Numer NIP" required fullWidth variant="outlined" type="text"
            margin="normal"
            error={formik.touched.nipNumber && Boolean(formik.errors.nipNumber)}
            id="nipNumber"
            inputProps={{ maxLength: 10 }}
            onBlur={formik.handleBlur}
            value={formik.values.nipNumber}
            onChange={(val) => {
              const sanitzed_val = val.target.value.replaceAll(/[^0-9]/g, "");
              formik.handleChange("nipNumber")(sanitzed_val)
            }} />
          <TextField label="Nazwa firmy" required fullWidth variant="outlined" type="text"
            id="name"
            margin="normal"
            value={formik.values.name}
            error={formik.touched.name && Boolean(formik.errors.name)}
            onBlur={formik.handleBlur}
            onChange={formik.handleChange} />
          <TextField label="Adres firmy" required fullWidth variant="outlined" type="text"
            margin="normal"
            id="address"
            value={formik.values.address}
            helperText={formik.touched.address && formik.errors.address}
            error={formik.touched.address && Boolean(formik.errors.address)}
            onChange={formik.handleChange}
            onBlur={formik.handleBlur} />
        </Grid>
        <Grid item>
          <FormControl error={formik.touched.taxSchema && Boolean(formik.errors.taxSchema)}>
            <Select displayEmpty
              value={formik.values.taxSchema}
              onChange={formik.handleChange}
              onBlur={formik.handleBlur}
              error={formik.touched.taxSchema && Boolean(formik.errors.taxSchema)}
              // helperText={}
              id="taxSchema"
              name="taxSchema"
            >
              <MenuItem value="" disabled>
                {"<Wybierz formę opodatkowania>"}
              </MenuItem>
              <MenuItem value="1" disabled>
                Zasady ogólne (18%/32%)
              </MenuItem>
              <MenuItem value="2">
                Podatek liniowy (19%)
              </MenuItem>
              <MenuItem value="3" disabled>
                Ryczałt
              </MenuItem>
            </Select>
            {formik.touched.taxSchema && formik.errors.taxSchema ?
              <FormHelperText>{formik.errors.taxSchema}</FormHelperText> :
              null}
          </FormControl>

        </Grid>
        <Grid item>
          <Button
            type="submit"

            primary
            isLoading={enterpriseAdd.isLoading}
            disabled={(!formik.isValid)}>
            Dodaj
          </Button>
        </Grid>
        <Grid item>
          <Button
            onClick={prevPageHandler}
            primary>
            Wstecz
          </Button>
        </Grid>

        {enterpriseAdd.isSuccess ? <Redirect to="/" /> : <></>}
      </Grid >
    </form>
  )
}