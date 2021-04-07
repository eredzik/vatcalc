# About
Application for vat and small entity tax calculations together with sending JPK_VAT files.
Frontend part is written in Elm and backend in Python with use of Fastapi. All parts are connected with docker and docker-compose.

# How to run
Use `docker-compose up` or `run_backend_dev` from `scripts` directory.

# How to build
To regenerate auto generated `elm-graphql` source and build frontend use `./scripts/build_frontend.sh`



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
