import { Controller, Get } from "@nestjs/common";
import { MenuItem, MenuService } from "./menu.service";

@Controller("menu")
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  findAll(): MenuItem[] {
    return this.menuService.findAll();
  }
}
