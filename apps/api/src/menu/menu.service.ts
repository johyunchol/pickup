import { Injectable } from "@nestjs/common";

export interface MenuItem {
  id: number;
  name: string;
  price: number;
}

// 샘플용 하드코딩 메뉴 — DB 연결 전까지 사용한다.
const MENU: MenuItem[] = [
  { id: 1, name: "아메리카노", price: 4500 },
  { id: 2, name: "카페라떼", price: 5000 },
  { id: 3, name: "바닐라라떼", price: 5500 },
];

@Injectable()
export class MenuService {
  findAll(): MenuItem[] {
    return MENU;
  }
}
