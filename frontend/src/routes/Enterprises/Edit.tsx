import { useMemo } from "react";
import { useHistory, useParams } from "react-router";
import { useTable } from "react-table";
import { Button } from "semantic-ui-react";
import { Layout } from "../../../components/Layout";
import SimpleTable from "../../../components/SimpleTable";
import { VatRateResponse } from "../../generated-api";
import { useVatRateList } from "../../hooks/vatratesApi";

export default function EnterpriseEdit() {
  const history = useHistory();
  const { enterprise_id } = useParams<{ enterprise_id: string }>();
  const page = 1;
  const vatrates = useVatRateList(page, parseInt(enterprise_id));
  const table = useTable({
    columns: useMemo(
      () => [
        { Header: "Stawka vat", accessor: (r: VatRateResponse) => r.vat_rate },
        { Header: "Opis", accessor: (r: VatRateResponse) => r.comment },
      ],
      []
    ),
    data: useMemo(() => vatrates.data?.data || [], [vatrates.data]),
  });
  return (
    <Layout>
      <SimpleTable react_table={table} />
      <Button
        primary
        content="Dodaj stawkę VAT"
        onClick={() => history.push(history.location.pathname + "/vatrate/add")}
        type="button"
      />
      <Button
        secondary
        content="Cofnij"
        onClick={() => history.goBack()}
        type="button"
      />
    </Layout>
  );
}
