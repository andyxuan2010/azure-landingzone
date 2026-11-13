# Module tagging contract

Reusable modules consume tags from the composition/root module. They should not normalize enterprise taxonomy on their own.

## Inputs

Modules that support tag inheritance expose:

```hcl
variable "inherit_resource_group_tags" {
  type    = bool
  default = true
}

variable "inherited_resource_group_tags" {
  type    = map(string)
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

## Behavior

Modules merge tags in this order:

```hcl
merge(
  inherited_or_resource_group_tags,
  var.tags
)
```

The root composition is responsible for normalized enterprise tags such as:

- `Environment`
- `Workload`

Modules should not maintain their own `environment_tag_map` for resource tags or override `Environment` and `Workload` after receiving inherited tags.

## Azure Policy compatibility

`inherit_resource_group_tags` remains enabled by default because some environments also use Azure Policy to enforce or remediate resource-group tag inheritance.

When `inherited_resource_group_tags` is provided, modules use that plan-known map and avoid reading resource group tags during the plan. When it is `null`, modules may fall back to reading the target resource group so standalone module usage remains compatible.
