import { Invoice, Prisma } from "@prisma/client";
import { GetServerSideProps, InferGetServerSidePropsType } from "next";
import { getSession, useSession } from "next-auth/react";
import Link from "next/link";
import { useMemo } from "react";
// import { useHistory } from "react-router-dom";
import { useTable } from "react-table";
import { Button, Table } from "semantic-ui-react";
import { Layout } from "../../components/Layout";
import { trpc } from "../../utils/trpc";
// import { InvoiceListResponse } from "../../generated-api";
// import { useInvoiceList } from "../../hooks/invoicesApi";
export const getServerSideProps: GetServerSideProps = async (context) => {
  const session = await getSession();
  if (session) {
    const invoices =
      trpc.useQuery([
        "invoices.getEnterpriseInvoicesSummary",
        { enterprise_id: session.user.fav_enterprise_id || 1 },
      ]) || [];
    return { props: { invoices } };
  }
  return { props: { invoices: [] } };
};

export default function InvoicesList({
  invoices,
}: InferGetServerSidePropsType<typeof getServerSideProps>) {
  // const columns = useMemo(
  //   () => [
  //     {
  //       Header: "NIP kontrahenta",
  //       accessor: (r: Prisma.InvoiceInclude) => r,
  //     },
  //     {
  //       Header: "Nazwa firmy",
  //       accessor: (r: Invoice) => r.trading_partner_name,
  //     },
  //     {
  //       Header: "Numer faktury",
  //       accessor: (r: Invoice) => r.invoice_business_id,
  //     },
  //     {
  //       Header: "Data wystawienia",
  //       accessor: (r: Invoice) => r.invoice_date,
  //     },
  //   ],
  //   []
  // );
  // const page = 1;
  // //   const data = useInvoiceList(page);
  // console.log(data);
  // const table = useTable({
  //   columns,
  //   data: invoices,
  // });
  // const history = useHistory();
  return (
    <Layout>
      <Table>
        <Table.Header>
          <Table.Row>
            {/* {table.headerGroups.map((header_group) =>
              header_group.headers.map((column) => (
                <Table.HeaderCell>{column.render("Header")}</Table.HeaderCell>
              ))
            )} */}
          </Table.Row>
        </Table.Header>
      </Table>
      <Link href="invoices/add">
        <Button color="green" content="Dodaj fakturę" />
      </Link>
    </Layout>
  );
}

InvoicesList.auth = true;
