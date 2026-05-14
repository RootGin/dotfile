let
  user = "age15hpy92757w3zn25u6j5pufcg6zjy57d25sjrs9q6rzdy2n4g3fqsx25nnx";
in
{
  "deepseek-api-key.age".publicKeys = [ user ];
  "qwen-api-key.age".publicKeys = [ user ];
  "rootgin-password-hash.age".publicKeys = [ user ];
}
