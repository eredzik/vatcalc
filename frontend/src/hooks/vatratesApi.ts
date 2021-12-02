import { QueryClient, useMutation, useQuery } from "react-query";
import { VatRateApi, VatrateInput } from "../generated-api";
import { apiConfig } from "./userApi";


const vatrateApi = new VatRateApi(apiConfig);
const queryClient = new QueryClient()

export function useVatRateList(page: number, enterprise_id: number) {
    return useQuery(
        ['vatrate_list', page, enterprise_id],
        async () => {
            return vatrateApi.getVatRatesVatrateGet(page, enterprise_id)
        }
    )
}

export function useVatRateAddMutation() {
    return useMutation(
        async (vatrateInput: VatrateInput) => {
            const response = await vatrateApi.addVatrateVatratePost(vatrateInput)
            if (response.status === 201) {
                queryClient.invalidateQueries('vatrate_list')
                return response
            } else {
                throw response
            }
        }
    )
}