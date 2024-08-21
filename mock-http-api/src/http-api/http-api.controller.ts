import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpException,
  HttpStatus,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { Transform, plainToInstance } from 'class-transformer';
import { IsNotEmpty, IsOptional } from 'class-validator';
import {
  Provider,
  ProviderWithDefinition,
  VariableValue,
  VariableValueWithDefinition,
} from './dto';
import {
  getProvider,
  getProviders,
  getVariable,
  getVariablesByPrefixes,
  hasWriteRequestReadonlyVariables,
} from './mock-data';

class VariableQueryParameters {
  @IsOptional()
  @Transform(({ value }) => {
    return value === 'true' ? true : false;
  })
  definition: boolean;
}

class VariablesQueryParameters {
  @IsOptional()
  @Transform(({ value }) => {
    return value === 'true' ? true : false;
  })
  definition: boolean;

  @Transform(({ value }) => value.split(','))
  prefixes: string[];
}

class ProviderPathParameter {
  @IsNotEmpty()
  providerId: string;
}

type VariablesPathParameter = ProviderPathParameter;

class VariablePathParameter extends ProviderPathParameter {
  @IsNotEmpty()
  variableId: string;
}

@Controller('data-hub/api/v1')
export class HttpApiController {
  @Get('providers')
  listProviders(): Provider[] {
    return getProviders();
  }

  @Get('providers/:providerId')
  getProvider(
    @Param() params: ProviderPathParameter,
  ): Provider | ProviderWithDefinition {
    const providerId = params.providerId;
    return getProvider(providerId);
  }

  @Get('providers/:providerId/variables')
  getVariables(
    @Query() query,
    @Param() params: VariablesPathParameter,
  ): VariableValue[] | VariableValueWithDefinition[] {
    const providerId = params.providerId;

    const queryParams = plainToInstance(VariablesQueryParameters, query);

    return getVariablesByPrefixes(
      providerId,
      queryParams.prefixes || [],
      queryParams.definition,
    );
  }

  @Post('providers/:providerId/variables:batchUpdate')
  @HttpCode(200)
  updateVariables(
    @Body() updateVariablesDto: VariableValue[],
    @Param() params: VariablesPathParameter,
  ): VariableValue[] {
    const providerId = params.providerId;

    if (hasWriteRequestReadonlyVariables(providerId, updateVariablesDto)) {
      console.log('Updating readonly variable is not allowed.');
      throw new HttpException(
        {
          status: HttpStatus.BAD_REQUEST,
          error: 'Updating readonly variable is not allowed.',
        },
        HttpStatus.BAD_REQUEST,
      );
    }

    console.log(`Mock update for provider '${providerId}':`);
    updateVariablesDto.forEach((variable) =>
      console.log(
        `Variable '${variable.name}' updated to value '${variable.value}'.`,
      ),
    );

    return updateVariablesDto;
  }

  @Get('providers/:providerId/variables/:variableId')
  getVariable(
    @Query() query,
    @Param() params: VariablePathParameter,
  ): VariableValue | VariableValueWithDefinition {
    const providerId = params.providerId;
    const variableId = params.variableId;

    const queryParams = plainToInstance(VariableQueryParameters, query);

    return getVariable(providerId, variableId, queryParams.definition);
  }

  @Post('providers/:providerId/variables/:variableId')
  @HttpCode(200)
  updateVariable(
    @Body() updateVariableDto: VariableValue,
    @Param() params: VariablePathParameter,
  ): VariableValue {
    const providerId = params.providerId;
    const variableId = params.variableId;

    if (hasWriteRequestReadonlyVariables(providerId, [updateVariableDto])) {
      console.log('Updating readonly variable is not allowed.');
      throw new HttpException(
        {
          status: HttpStatus.BAD_REQUEST,
          error: 'Updating readonly variable is not allowed.',
        },
        HttpStatus.BAD_REQUEST,
      );
    }

    console.log(`Mock update for provider '${providerId}':`);

    console.log(
      `Variable '${variableId}' updated to value '${updateVariableDto.value}'.`,
    );

    return updateVariableDto;
  }
}
