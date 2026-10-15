import { Body, Controller, Get, Param, Patch } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { IdParam, MenuItem, UpdateMenuItemBody } from "@pickup/contract";
import { ContractResponse } from "../common/contract-response.decorator";
import { MenuService } from "./menu.service";

// 요청·응답의 모양은 계약(packages/contract)의 zod 스키마 — DTO 클래스를 따로 두지 않는다.
@ApiTags("menu")
@Controller("menu")
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  @ApiOperation({ summary: "메뉴 목록" })
  @ContractResponse(MenuItem, { isArray: true })
  listMenu(): MenuItem[] {
    return this.menuService.findAll();
  }

  @Patch(":id")
  @ApiOperation({ summary: "메뉴 품절 켜고 끄기 (사장님)" })
  @ContractResponse(MenuItem)
  updateMenuItem(
    @Param("id", { schema: IdParam }) id: number,
    @Body({ schema: UpdateMenuItemBody }) body: UpdateMenuItemBody,
  ): MenuItem {
    return this.menuService.setSoldOut(id, body.soldOut);
  }
}
