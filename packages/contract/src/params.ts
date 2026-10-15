import { z } from "zod";

/** 경로의 {id} — 문자열로 들어오니 숫자로 바꿔 받는다. */
export const IdParam = z.coerce.number<number>().int().positive();
