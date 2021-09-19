import io
from zeep import Client

# Essentials explained in comments

class REGONAPI:
    def __init__(self, WSDL):

        self.fields = ["Regon", "Nip", "StatusNip", "Nazwa", "Wojewodztwo", "Powiat", "Gmina", "Miejscowosc", "KodPocztowy",
                       "Ulica", "NrNieruchomosci", "NrLokalu", "Typ", "SilosID", "DataZakonczeniaDzialalnosci",
                       "MiejscowoscPoczty"]
        self.values = []
        self.client = Client(WSDL) # 1. Create zeep client with wsdl url

    def parse_xml(self, content, field_name, line):
        if f"  <{field_name}>" in line:
            start = content.find(f"<{field_name}>") + len(f"</{field_name}>") - 1
            end = content.find(f"</{field_name}>")
            value = content[start:end]
            self.values.append(value)
        elif f"  <{field_name} />" in line:
            value = ""
            self.values.append(value)
        return self.values

    def login(self, key):
        sid = self.client.service.Zaloguj(key) # 2. Pass the access key to login endpoint
        return sid # 3. Obtain access token

    def request(self, sid, params):
        keys = ["regon", "nip", "nip_status", "company_name", "voivodeship", "powiat", "gmina", "city",
                "postal_code", "street", "house_no", "suite_no", "type", "silos_id", "shutdown_date",
                "post_office_town"]
        with self.client.settings(extra_http_headers={"sid": sid}):
            # 4. Token must be passed as a HTTP header. "HTTP" is an important word here, as SOAP has a damn hell of different headers.
            response = self.client.service.DaneSzukajPodmioty(pParametryWyszukiwania=params)
            buf = io.StringIO(response)
            lines = buf.readlines()
            for field in self.fields:
                for line in lines:
                    self.parse_xml(response, field, line)
                    # 5. Response is an XML-ish string which, however, turned out to be problematic to deal with using
                    # BeautifulSoup or other XML parsers. Applied good ol' string slicing for extracting values,
                    # but this approach might be worth rethinking.
            json = {keys[i]: self.values[i] for i in range(len(keys))}
            return json