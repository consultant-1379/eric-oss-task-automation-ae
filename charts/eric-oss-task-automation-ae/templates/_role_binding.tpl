{{/* vim: set filetype=mustache: */}}

{{/*
Create a RoleBinding.

This named template must be called with a list of four arguments in the form:
(list $ . suffix sa)

$ is the root context of the calling template and is passed so that it can be restored here.
. passes in access to the contexts available in the calling template including things like .Values and .Release .
suffix is the string to append to the RoleBinding name
sa is the name ServiceAccount to bind to the privilegedPolicyClusterRoleName
*/}}
{{- define "eric-oss-task-automation-ae.role-binding" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $sa := index . 3 }}

{{- with index . 1 }}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ template "eric-oss-task-automation-ae.name" . }}-{{ template "eric-oss-task-automation-ae.privileged.cluster.role.name" . }}-{{ $suffix }}
  labels:
    app: {{ template "eric-oss-task-automation-ae.name" . }}
    chart: {{ template "eric-oss-task-automation-ae.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
  {{- include "eric-oss-task-automation-ae.kubernetes-io-info" .| nindent 4 }}
  annotations:
  {{- include "eric-oss-task-automation-ae.helm-annotations" .| nindent 4 }}
roleRef:
  kind: ClusterRole
  name: {{ template "eric-oss-task-automation-ae.privileged.cluster.role.name" . }}
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: {{ $sa }}
{{- end }}
{{- end -}}
