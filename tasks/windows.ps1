# groupmembers: 
#
# This task will add or remove users from a local group on the server.
# Only one group can be managed per task, but any number of members can be managed.
#
# The task will return the state of the local group after a successful run, and
# will error out with proper messages when invalid parameters were passed.
#
# Passing in a member that already exists in the group will not result in an error, and is idempotent.
#
# Parameters
# ----------
#
# * `ensure`
#   ENUM['present','absent']
#   When set to absent user accounts specified in the members parameter are removed.
#   When set to present user accounts specified in the members parameter are added.
#
# * `group`
#   String[1]
#   Group represents a local group. Ex: Administrators
#
# * `member`
#   Variant[String[1],Array[String[1]]]
#   Member represents the users to add or remove from the local group.
#
# @example Bolt run from Command Line
#   bolt task run groupmembers -n localhost 
#     --params '{
#      "ensure": "present", 
#      "group": "Administrators",
#      "member": [ "domain\\jdoe", "domain\\ffalor" 
#      }'
#
# Authors
# -------
#
# * Falor, Frank    <ffalorjr@outlook.com>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    $ensure,

    [Parameter(Mandatory = $True)]
    $group,

    [Parameter(Mandatory = $True)]
    $member
)

function write_error($ensure, $message, $group, $force, $skipped) {
    if (!($force)) {
        $members = get_members -group $group
    }
    else {
        $members = "Unable to get members of group."
    }

    if (!([String]::IsNullOrWhiteSpace($message))) {
        $message = $message | ConvertTo-Json
    }
    else {
        $message = '"No error message recieved."'
    }

    if (!([String]::IsNullOrWhiteSpace($skipped))) {
        $skipped = $skipped | ConvertTo-Json
    }
    else {
        $skipped = '"None"'
    }

    $error_payload = @"
{
    "_error": {
        "msg": $message,
        "kind": "puppetlabs.tasks/task-error",
        "details": {
            "group": "${group}",
            "members": ${members},
            "exitcode": 1
        }
    },
    "_output": "Something went wrong with task",
    "ensure": "${ensure}",
    "group": "${group}",
    "members": ${members},
    "skipped": ${skipped}
}
"@

    Write-Output $error_payload
}

function write_success($ensure, $group, $skipped) {
    try {

        $members = get_members -group $group

        if (!([String]::IsNullOrWhiteSpace($skipped))) {
            $skipped = $skipped | ConvertTo-Json
        }
        else {
            $skipped = '"None"'
        }

        $success_payload = @"
{
        "ensure": "${ensure}",
        "group": "${group}",
        "members": ${members},
        "skipped": ${skipped}
}
"@
        Write-Output $success_payload

    }
    catch {
        $error_message = $_.Exception.Message
        write_error -ensure $ensure -message $error_message -group $group -force $False -skipped $skipped
        exit 1
    }
}
function get_members($group) {
    try {

        $cmd = "net.exe localgroup `"${group}`""
        $result = cmd.exe /c $cmd
        if ($result.length -ge 1) {
            $result = $result[6..($result.length - 3)]
            return ConvertTo-Json -InputObject $result -Compress
        }
        else {
            return  '"No members returned."'
        }

    }
    catch {
        $error_message = $_.Exception.Message
        write_error -ensure $ensure -message $error_message -group $group -force $True
        exit 1
    }
}

function get_ps_version() {
    $ps_object = $PSVersionTable.PSVersion

    return $ps_object
}

$redirect = "2>&1"
try {
    $ps_version = get_ps_version
    if (($ps_version.major -eq 5) -and ($ps_version.minor -eq 1)) {
        if ($ensure -eq "present") {
            $command_error = New-Object System.Text.StringBuilder
            foreach ( $m in $member) {
                try {
                    Add-LocalGroupMember -Group "${group}" -Member "${m}" -ErrorAction Stop
                }
                catch {
                    $error_message = $_.Exception.Message
                    if ($error_message -notmatch "is already a member of group administrators.") {
                        write_error -ensure $ensure -message $error_message -group $group -force $False
                        exit 1
                    }
                }
            }
            write_success -ensure $ensure -group $group -force $False 
        } 
        elseif ($ensure -eq "absent") {
            foreach ( $m in $member) {
                try {
                    Remove-LocalGroupMember -Group "${group}" -Member $member -ErrorAction Stop
                }
                catch {
                    $error_message = $_.Exception.Message
                    if ($error_message -notmatch "was not found in group administrators") {
                        write_error -ensure $ensure -message $error_message -group $group -force $False
                        exit 1
                    }
                }
            }
            write_success -ensure $ensure -group $group -force $False 
        }
    }
    else {
        if ($ensure -eq "present") {
            $command_error = New-Object System.Text.StringBuilder
            $skipped = @()
            foreach ( $m in $member) {
                if ($m.length -ge 20) { 
                    $skipped += $m
                    continue 
                }
                $cmd = "net.exe localgroup `"${group}`" `"${m}`" /add"
                $temp_output = cmd.exe /c $cmd $redirect
                if ($LASTEXITCODE -ne 0 -and $temp_output[2] -ne "The specified account name is already a member of the group.") {
                    $command_error.Append($temp_output[0]) | Out-Null
                    $command_error.Append(" " + $temp_output[2]) | Out-Null
                    write_error -ensure $ensure -message $command_error.ToString() -group $group -force $False -skipped $skipped
                    exit 1
                }
            }
            write_success -ensure $ensure -group $group -force $False -skipped $skipped

        }
        elseif ($ensure -eq "absent") {
            $command_error = New-Object System.Text.StringBuilder
            $skipped = @()
            foreach ( $m in $member) {
                if ($m.length -ge 20) { 
                    $skipped += $m
                    continue 
                }
                $cmd = "net.exe localgroup `"${group}`" `"${m}`" /delete"
                $temp_output = cmd.exe /c $cmd $redirect
                if ($LASTEXITCODE -ne 0 -and $temp_output[2] -ne "The specified account name is not a member of the group.") {
                    $command_error.Append($temp_output[0]) | Out-Null
                    $command_error.Append(" " + $temp_output[2]) | Out-Null
                    write_error -ensure $ensure -message $command_error.ToString() -group $group -force $False -skipped $skipped
                    exit 1
                }
            }
            write_success -ensure $ensure -group $group -force $False -skipped $skipped
        }
    }
}
catch {
    $error_message = $_.Exception.Message
    write_error -ensure $ensure -message $error_message -group $group -force $False
    exit 1
}