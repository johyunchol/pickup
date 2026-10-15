import { Injectable, NotFoundException } from "@nestjs/common";
import type { MenuItem } from "@pickup/contract";

// 시드 메뉴 — 메모리에만 둔다. 서버를 다시 켜면 품절 표시도 처음으로 돌아간다.
const SEED: MenuItem[] = [
  { id: 1, name: "아메리카노", description: "진하고 깔끔한 기본 한 잔", category: "coffee", price: 4500, soldOut: false },
  { id: 2, name: "카페라떼", description: "고소한 우유와 에스프레소", category: "coffee", price: 5000, soldOut: false },
  { id: 3, name: "바닐라라떼", description: "직접 끓인 바닐라 시럽", category: "coffee", price: 5500, soldOut: false },
  { id: 4, name: "콜드브루", description: "12시간 천천히 내린 커피", category: "coffee", price: 5000, soldOut: true },
  { id: 5, name: "말차라떼", description: "제주 말차로 쌉싸름하게", category: "non_coffee", price: 5800, soldOut: false },
  { id: 6, name: "버터 스콘", description: "매일 아침 굽는 스콘", category: "dessert", price: 3800, soldOut: false },
];

@Injectable()
export class MenuService {
  private readonly items = SEED.map((item) => ({ ...item }));

  findAll(): MenuItem[] {
    return this.items;
  }

  findOne(id: number): MenuItem {
    const item = this.items.find((m) => m.id === id);
    if (!item) {
      throw new NotFoundException({ statusCode: 404, code: "NOT_FOUND", message: `메뉴를 찾을 수 없어요 (id ${id})` });
    }
    return item;
  }

  setSoldOut(id: number, soldOut: boolean): MenuItem {
    const item = this.findOne(id);
    item.soldOut = soldOut;
    return item;
  }
}
