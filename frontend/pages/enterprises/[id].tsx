import { VatRate } from "@prisma/client";
import Link from "next/link";
import { useRouter } from "next/router";
import { useMemo } from "react";
// import { useHistory, useParams } from "react-router";
import { useTable } from "react-table";
import { Button } from "semantic-ui-react";
import { Layout } from "../../components/Layout";
import SimpleTable from "../../components/SimpleTable";
import { trpc } from "../../utils/trpc";
// import { VatRateResponse } from "../../generated-api";
// import { useVatRateList } from "../../hooks/vatratesApi";

export default function EnterpriseEdit() {
  // const history = useHistory();
  // const { enterprise_id } = useParams<{ enterprise_id: string }>();
  const router = useRouter();
  const page = 1;
  const vatrates = trpc.useQuery([
    "enterprises.listVatrates",
    { enterprise_id: parseInt(router.query.id as string, 10) },
  ]);
  // const vatrates = useVatRateList(page, parseInt(enterprise_id));
  const table = useTable({
    columns: useMemo(
      () => [
        { Header: "Stawka vat", accessor: (r: VatRate) => r.vat_rate },
        { Header: "Opis", accessor: (r: VatRate) => r.comment },
      ],
      []
    ),
    data: useMemo(() => vatrates.data || [], [vatrates.data]),
  });
  return (
    <Layout>
      <SimpleTable react_table={table} />
      <Link href="/vatrate/add">
        <Button
          primary
          content="Dodaj stawkę VAT"
          // onClick={() => history.push(history.location.pathname + "/vatrate/add")}
          type="button"
        />
      </Link>
      <Link href="/enterprises">
        <Button
          secondary
          content="Cofnij"
          // onClick={() => history.goBack()}
          type="button"
        />
      </Link>
    </Layout>
  );
}
