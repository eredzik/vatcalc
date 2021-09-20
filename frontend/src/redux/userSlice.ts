import { createAsyncThunk, createSlice, PayloadAction } from "@reduxjs/toolkit";
import { apiConfig } from "../api";
import { CurrentUserResponse, UserApi } from "../generated";
function getInitUser(): CurrentUserResponse | null {
  const storagecontents = localStorage.getItem("userState");
  console.log(storagecontents)
  if (storagecontents) {
    return JSON.parse(storagecontents);
  }
  return null;
}

export const fetchUser = createAsyncThunk(
  'user/fetchUser',
  async () => {
    const user = await new UserApi(apiConfig).getUserDataUserMeGet();
    return user.data as CurrentUserResponse
  });
interface UserState {
  user: CurrentUserResponse | null
  loading: 'idle' | 'pending' | 'succeeded' | 'failed'
  error: string | undefined
}
export const userSlice = createSlice({
  name: "user",
  initialState: {
    user: getInitUser(),
    loading: "idle",
    error: undefined
  } as UserState,
  reducers: {
    updateUser: (state, action: PayloadAction<CurrentUserResponse | null>) => {
      state.user = action.payload;
    },
  },
  extraReducers: builder => {
    builder
      .addCase(fetchUser.pending, (state, action) => {
        state.loading = 'pending'
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.user = action.payload
        state.loading = "succeeded"
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.loading = 'failed'
        state.error = action.error.message
      })

  }
});
export const { updateUser } = userSlice.actions;
export default userSlice.reducer;
