# About
Application for vat and small entity tax calculations together with sending JPK_VAT files.
Frontend part is written in Elm and backend in Python with use of Fastapi.
Currently deployed [here](https://vatcalc-prod.herokuapp.com/).

# How to run local development
For development purposes uses docker and docker-compose.
Use `docker-compose up` from `scripts` directory.

# How to build
To regenerate frontend js use `./scripts/build_frontend.sh`

# Deployment
It is currently deployed on heroku.
Deployment requires setting following environment variables:
- `DB_URL`
- `JWT_SECRET`


# TODO
- [x] Trading partners adding and view
- [ ] Trading partners editing
- [ ] Deleting trading partners
- [x] View all invoices
- [x] Add invoice
- [ ] Delete invoice
- [ ] Edit invoice
- [x] Register/Login
- [ ] Company data
- [ ] Outstanding VAT calculation
- [ ] Deployment
- [ ] Automatic calculation of insurance payments (ZUS)
- [ ] Automatic calculation of income tax
- [ ] Generation of JPK_VAT xml file
- [ ] Sending of JPK_VAT
- [ ] PDF to text automatic input
