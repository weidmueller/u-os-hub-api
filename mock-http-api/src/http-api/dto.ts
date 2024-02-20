export class Provider {
  // Relative resource name without leading slash.
  name: string;

  description: string;

  links: Links;
}

export class ProviderWithDefinition extends Provider {
  definitions: Definition[];
}

export class Links {
  [key: string]: string;
}

export class Definition {
  name: string;
  datatype: 'boolean' | 'datetime' | 'double' | 'int64' | 'string';
  accesstype: 'readonly' | 'readwrite';
}

export class VariableValue {
  name: string;
  value: string | number | boolean;
}

export class VariableValueWithDefinition extends VariableValue {
  definition: {
    datatype: 'boolean' | 'datetime' | 'double' | 'int64' | 'string';
    accesstype: 'readonly' | 'readwrite';
  };
}
