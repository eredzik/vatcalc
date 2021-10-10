import { useQuery } from "react-query";
import { VatRateApi } from "../generated-api";
import { apiConfig } from "./userApi";


const vatrateApi = new VatRateApi(apiConfig);
export function useVatRateList(page: number, enterprise_id: number) {
    return useQuery(
        ['vatrate_list', page, enterprise_id],
        async () => {
            return vatrateApi.getVatRatesVatrateGet(page, enterprise_id)
        }
    )
}