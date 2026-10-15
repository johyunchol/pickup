import { z } from "zod";

// .meta({ id }) 가 OpenAPI 문서의 components.schemas 이름이 되고, 그 이름이 그대로 Dart 클래스 이름이 된다.

export const MenuCategory = z
  .enum(["coffee", "non_coffee", "dessert"])
  .meta({ id: "MenuCategory", description: "메뉴 분류 — 손님 앱의 카테고리 칩과 같다" });
export type MenuCategory = z.infer<typeof MenuCategory>;

export const MenuItem = z
  .object({
    id: z.int().positive(),
    name: z.string(),
    description: z.string(),
    category: MenuCategory,
    price: z.int().nonnegative().meta({ description: "원 단위 가격" }),
    soldOut: z.boolean(),
  })
  .meta({ id: "MenuItem" });
export type MenuItem = z.infer<typeof MenuItem>;

export const UpdateMenuItemBody = z
  .object({
    soldOut: z.boolean(),
  })
  .meta({ id: "UpdateMenuItemBody" });
export type UpdateMenuItemBody = z.infer<typeof UpdateMenuItemBody>;
