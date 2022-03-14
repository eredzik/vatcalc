import React from "react";
import { useHistory } from "react-router-dom";
import { useTable } from "react-table";
import { Button, Table } from "semantic-ui-react";
import { Layout } from "../../components/Layout";
import { InvoiceListResponse } from "../../generated-api";
import { useInvoiceList } from "../../hooks/invoicesApi";
export function InvoicesList() {
  const columns = React.useMemo(
    () => [
      {
        Header: "NIP kontrahenta",
        accessor: (r: InvoiceListResponse) => r.trading_partner_nip,
      },
      {
        Header: "Nazwa firmy",
        accessor: (r: InvoiceListResponse) => r.trading_partner_name,
      },
      {
        Header: "Numer faktury",
        accessor: (r: InvoiceListResponse) => r.invoice_business_id,
      },
      {
        Header: "Data wystawienia",
        accessor: (r: InvoiceListResponse) => r.invoice_date,
      },
    ],
    []
  );
  const page = 1;
  const data = useInvoiceList(page);
  console.log(data);
  const table = useTable({
    columns,
    data: data.data?.data || ([] as InvoiceListResponse[]),
  });
  const history = useHistory();
  return (
    <Layout>
      <Table>
        <Table.Header>
          <Table.Row>
            {table.headerGroups.map((header_group) =>
              header_group.headers.map((column) => (
                <Table.HeaderCell>{column.render("Header")}</Table.HeaderCell>
              ))
            )}
          </Table.Row>
        </Table.Header>
      </Table>
      <Button
        color="green"
        content="Dodaj fakturę"
        onClick={() => history.push("invoice/add")}
      />
    </Layout>
  );
}
