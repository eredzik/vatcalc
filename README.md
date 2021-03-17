# About
Application for vat and small entity tax calculations together with sending JPK_VAT files.
Frontend part is written in Elm and backend in Python with use of Fastapi. All parts are connected with docker and docker-compose.

# How to run
Backend : use `docker-compose up` or `run_backend_dev` from `scripts` directory.
Frontend : use `elm reactor` in `frontend` directory.

# How to build
To regenerate auto generated `elm-graphql` source and build frontend use `make`



# TODO
- [x] Trading partners adding and view
- [ ] Trading partners editing
- [ ] Inbound and outbound invoices adding and view
- [ ] Invoices editing
- [ ] Outstanding VAT calculation
- [ ] Deployment
- [ ] Automatic calculation of insurance payments (ZUS)
- [ ] Automatic calculation of income tax
- [ ] Generation of JPK_VAT xml file
- [ ] Sending of JPK_VAT
- [ ] PDF to text automatic input
