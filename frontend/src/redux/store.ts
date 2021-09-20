import { configureStore } from "@reduxjs/toolkit";
import userReducer from "./userSlice";
import enterprisesReducer from "./enterprisesSlice";
const store = configureStore({
  reducer: {
    user: userReducer,
    enterprise: enterprisesReducer
  },
});
store.subscribe(() => {
  localStorage.setItem("userState", JSON.stringify(store.getState().user.user));
});
export default store;
export type RootState = ReturnType<typeof store.getState>;
