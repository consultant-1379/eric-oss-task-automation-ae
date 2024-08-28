{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-oss-task-automation-ae.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-oss-task-automation-ae.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create version
*/}}
{{- define "eric-oss-task-automation-ae.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Release name
 */}}
{{- define "eric-oss-task-automation-ae.release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-oss-task-automation-ae.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-oss-task-automation-ae.helm-annotations" }}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end }}

{{/*
Create image pull secrets for keycloak client
*/}}
{{- define "eric-oss-task-automation-ae.pullSecrets" -}}
{{- if .Values.imageCredentials -}}
  {{- if .Values.imageCredentials.pullSecret -}}
    {{- print .Values.imageCredentials.pullSecret -}}
  {{- end -}}
  {{- else if .Values.global.pullSecret -}}
    {{- print .Values.global.pullSecret -}}
  {{- end -}}
{{- end -}}

{{/*
Define a imagePath template for all images in eric-product-info.yaml (DR-D1121-067)
*/}}
{{- define "eric-oss-task-automation-ae.imagePath" }}
    {{- $imageId := index . "imageId" -}}
    {{- $values := index . "values" -}}
    {{- $files := index . "files" -}}
    {{- $productInfo := fromYaml ($files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := index $productInfo "images" $imageId "registry" -}}
    {{- $repoPath := index $productInfo "images" $imageId "repoPath" -}}
    {{- $name := index $productInfo "images" $imageId "name" -}}
    {{- $tag :=  index $productInfo "images" $imageId "tag" -}}
    {{- if $values.global -}}
        {{- if $values.global.registry -}}
            {{- $registryUrl = default $registryUrl $values.global.registry.url -}}
        {{- end -}}
    {{- end -}}
    {{- if $values.imageCredentials -}}
        {{- if $values.imageCredentials.registry -}}
            {{- $registryUrl = default $registryUrl $values.imageCredentials.registry.url -}}
        {{- end -}}
        {{- if not (kindIs "invalid" $values.imageCredentials.repoPath) -}}
            {{- $repoPath = $values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- $image := index $values.imageCredentials $imageId -}}
        {{- if $image -}}
            {{- if $image.registry -}}
                {{- $registryUrl = default $registryUrl $image.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" $image.repoPath) -}}
                {{- $repoPath = $image.repoPath -}}
            {{- end -}}
            {{- if not (kindIs "invalid" $image.tag) -}}
                {{- $tag = $image.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-oss-task-automation-ae.nodeSelector" -}}
{{- $globalValue := (dict) -}}
{{- if .Values.global -}}
    {{- if .Values.global.nodeSelector -}}
      {{- $globalValue = .Values.global.nodeSelector -}}
    {{- end -}}
{{- end -}}
{{- if .Values.nodeSelector -}}
  {{- range $key, $localValue := .Values.nodeSelector -}}
    {{- if hasKey $globalValue $key -}}
         {{- $Value := index $globalValue $key -}}
         {{- if ne $Value $localValue -}}
           {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
         {{- end -}}
     {{- end -}}
    {{- end -}}
    nodeSelector: {{- toYaml (merge $globalValue .Values.nodeSelector) | trim | nindent 2 -}}
{{- else -}}
  {{- if not ( empty $globalValue ) -}}
    nodeSelector: {{- toYaml $globalValue | trim | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Service Mesh: service-mesh-enabled setting
*/}}

{{- define "eric-oss-task-automation-ae.service-mesh.enabled" }}
  {{- $globalMeshEnabled := "false" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.serviceMesh -}}
        {{- $globalMeshEnabled = .Values.global.serviceMesh.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $globalMeshEnabled -}}
{{- end -}}

{{/*
Create Service Mesh Ingress enabling option
*/}}
{{- define "eric-oss-task-automation-ae.service-mesh-ingress.enabled" -}}
{{ if .Values.global.serviceMesh }}
  {{ if .Values.global.serviceMesh.ingress }}
    {{ if .Values.global.serviceMesh.ingress.enabled }}
  {{- print "true" -}}
    {{ else }}
  {{- print "false" -}}
    {{- end -}}
  {{ else }}
    {{- print "false" -}}
  {{- end -}}
{{ else }}
  {{- print "false" -}}
{{ end }}
{{- end}}

{{/*
DR-D1121-102 main image pull policy
*/}}

{{- define "eric-oss-task-automation-ae.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}

{{/*
The name of the cluster role used during openshift deployments.
This helper is provided to allow use of the new global.security.privilegedPolicyClusterRoleName if set, otherwise
use the previous naming convention of <release_name>-allowed-use-privileged-policy for backwards compatibility.
*/}}
{{- define "eric-oss-task-automation-ae.privileged.cluster.role.name" -}}
  {{- if hasKey (.Values.global.security) "privilegedPolicyClusterRoleName" -}}
    {{ .Values.global.security.privilegedPolicyClusterRoleName }}
  {{- else -}}
    {{ template "eric-oss-task-automation-ae.release.name" . }}-allowed-use-privileged-policy
  {{- end -}}
{{- end -}}

{{/*
check global.security.tls.enabled
*/}}
{{- define "eric-oss-task-automation-ae.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
      {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
      {{- "false" -}}
    {{- end -}}
  {{- else -}}
    {{- "false" -}}
  {{- end -}}
{{- else -}}
  {{- "false" -}}
{{- end -}}
{{- end -}}
