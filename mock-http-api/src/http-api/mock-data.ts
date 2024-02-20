import { Provider, VariableValue, VariableValueWithDefinition } from './dto';

export const PROVIDERS: Provider[] = [
  {
    name: 'providers/web-plc',
    description: 'Weidmueller web-plc provider.',
    links: {
      variables:
        'http://localhost:3000/uc-hub/api/v1/providers/web-plc/variables',
    },
  },
  {
    name: 'providers/sys',
    description: 'System data provider',
    links: {
      variables: 'http://localhost:3000/uc-hub/api/v1/providers/sys/variables',
    },
  },
];

export const VARIABLE_VALUE_WEB_PLC: VariableValue[] = [
  {
    name: 'providers/web-plc/variables/gvl/input-1',
    value: true,
  },
  {
    name: 'providers/web-plc/variables/gvl/output-1',
    value: false,
  },
  {
    name: 'providers/web-plc/variables/test/output-1',
    value: false,
  },
  {
    name: 'providers/web-plc/variables/test/foo',
    value: 45,
  },
];

export const VARIABLE_VALUE_WITH_DEFINITION_WEB_PLC: VariableValueWithDefinition[] =
  [
    {
      name: 'providers/web-plc/variables/gvl/input-1',
      value: true,
      definition: {
        datatype: 'boolean',
        accesstype: 'readonly',
      },
    },
    {
      name: 'providers/web-plc/variables/gvl/output-1',
      value: false,
      definition: {
        datatype: 'boolean',
        accesstype: 'readwrite',
      },
    },
    {
      name: 'providers/web-plc/variables/test/output-1',
      value: false,
      definition: {
        datatype: 'boolean',
        accesstype: 'readwrite',
      },
    },
    {
      name: 'providers/web-plc/variables/test/foo',
      value: 45,
      definition: {
        datatype: 'int64',
        accesstype: 'readwrite',
      },
    },
  ];

export const VARIABLE_VALUE_SYS: VariableValue[] = [
  {
    name: 'providers/sys/variables/info/memory',
    value: 44.7,
  },
];

export const VARIABLE_VALUE_WITH_DEFINITION_SYS: VariableValueWithDefinition[] =
  [
    {
      name: 'providers/sys/variables/info/memory',
      value: 44.7,
      definition: {
        datatype: 'double',
        accesstype: 'readonly',
      },
    },
  ];

export function getProviders(): Provider[] {
  return PROVIDERS;
}

export function getProvider(providerId: string): Provider {
  return PROVIDERS.find(
    (provider) => provider.name === `providers/${providerId}`,
  );
}

function getVariableValues(
  providerId: string,
  withDefinition: boolean,
): VariableValue[] | VariableValueWithDefinition[] {
  if (providerId === 'web-plc') {
    return withDefinition
      ? VARIABLE_VALUE_WITH_DEFINITION_WEB_PLC
      : VARIABLE_VALUE_WEB_PLC;
  }

  if (providerId === 'sys') {
    return withDefinition
      ? VARIABLE_VALUE_WITH_DEFINITION_SYS
      : VARIABLE_VALUE_SYS;
  }
}

export function getVariablesByPrefixes(
  providerId: string,
  prefixes: string[],
  withDefinition: boolean,
): VariableValue[] | VariableValueWithDefinition[] {
  const variableValues = getVariableValues(providerId, withDefinition);

  if (prefixes.length === 0) {
    return variableValues;
  }

  const matchingVariables = variableValues.filter((variable) => {
    const match = prefixes.find((prefix) =>
      variable.name.startsWith(`providers/${providerId}/variables/${prefix}`),
    );

    if (!match) {
      return false;
    }

    return true;
  });

  // remove duplicates
  return matchingVariables.filter(
    (variable, index) => matchingVariables.indexOf(variable) === index,
  );
}

export function getVariable(
  providerId: string,
  variableId: string,
  withDefinition: boolean,
): VariableValue | VariableValueWithDefinition {
  const variableValues = getVariableValues(providerId, withDefinition);

  return variableValues.find(
    (variable) =>
      variable.name === `providers/${providerId}/variables/${variableId}`,
  );
}

export function hasWriteRequestReadonlyVariables(
  providerId: string,
  variables: VariableValue[],
): boolean {
  const variableValues = getVariableValues(
    providerId,
    true,
  ) as VariableValueWithDefinition[];
  const readonlyVariables = variableValues.filter(
    (variableValue) => variableValue.definition.accesstype === 'readonly',
  );

  const readonlyMatch = variables.find((variable) => {
    const isReadonlyVariable = readonlyVariables.find(
      (readonlyVariable) => readonlyVariable.name === variable.name,
    );

    return isReadonlyVariable ? true : false;
  });

  return readonlyMatch ? true : false;
}
