{{- define "eric-oss-task-automation-ae.product-info" }}
ericsson.com/product-name: "OSS TaskAutomation"
ericsson.com/product-number: "CXF 101 0224"
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+].*" .Chart.Version "${1}" }}
{{- end }}