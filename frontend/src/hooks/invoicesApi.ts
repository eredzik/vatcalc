import { useQuery } from "react-query";
import { InvoiceApi } from "../generated-api";
import { apiConfig, useUser } from "./userApi";


const invoicesApi = new InvoiceApi(apiConfig);
export function useInvoiceList(page: number) {
    const user = useUser()
    return useQuery(['invoice_list', page],
        async () =>
            invoicesApi
                .getInvoiceListInvoiceListGet(
                    page,
                    user.data?.data.fav_enterprise_id || -1)
        , { enabled: !!user.data?.data.fav_enterprise_id }
    )
}