import { Module } from '@nestjs/common';
import { HttpApiService } from './http-api/http-api.service';
import { HttpApiController } from './http-api/http-api.controller';

@Module({
  controllers: [HttpApiController],
  providers: [HttpApiService],
})
export class AppModule {}
