<?php

$id = $_GET["app-id"];
$commit = $_GET["commit"];
$version = 0;
$json = "./.versions/$id.json";

if (!file_exists($json)) {
	file_put_contents($json, json_encode(array("-" => 0)));
}

$all = json_decode(file_get_contents($json), true);

if (isset($_GET["force"])) {
	$all[$commit] = intval($_GET["force"]);
	$version = intval($_GET["force"]);
}
else if (isset($all[$commit])) {
	$version = $all[$commit];
}
else {
	$version = max(array_values($all)) + 1;
	$all[$commit] = $version;
}

file_put_contents($json, json_encode($all));
header('Content-Type: application/json');
echo "{\"build\": ".$version."}\n";
