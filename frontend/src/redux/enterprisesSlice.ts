import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { apiConfig } from "../api";
import { EnterpriseApi, EnterpriseResponse } from "../generated";

export const fetchEnterprises = createAsyncThunk('enterprises/fetchEnterprises',
  async () => {
    const result = await new EnterpriseApi(apiConfig)
      .getUserEnterprisesEnterpriseGet(1)
    return result.data
  })


interface EnterpriseState {
  enterprises: EnterpriseResponse[]
  loading: 'idle' | 'pending' | 'succeeded' | 'failed'
  error: string | undefined
}
export const enterpriseSlice = createSlice({
  name: "enterprises",
  initialState: {
    enterprises: [] as EnterpriseResponse[],
    loading: 'idle',
    error: undefined
  } as EnterpriseState,
  reducers: {
    gotResponse: (state, action: { payload: EnterpriseResponse[] }) => {
      state.enterprises = action.payload;
    },
  },
  extraReducers: (builder) => (
    builder
      .addCase(fetchEnterprises.fulfilled, (state, action) => {
        state.enterprises = action.payload
        state.loading = "succeeded"
      })
      .addCase(fetchEnterprises.rejected, (state, action) => {
        state.loading = "failed"
        state.error = action.error.message
      })
  )
});

export const { gotResponse } = enterpriseSlice.actions;
export default enterpriseSlice.reducer;
