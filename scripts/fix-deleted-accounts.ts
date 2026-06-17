const SOCIAL_BASE_URL = "https://integralces.net/ces/api/social"
const AUTH_BASE_URL = "https://integralces.net/oauth2"
const ACCOUNTING_BASE_URL = "https://accounting.komunitin.org"

const getToken = async (email: string, password: string) => {
  const response = await fetch(`${AUTH_BASE_URL}/token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "password",
      username: email,
      password: password,
      client_id: "komunitin-app",
      scope: "openid email profile komunitin_social komunitin_accounting offline_access komunitin_superadmin"
    }),
  })

  if (!response.ok) {
    const errorData = await response.json()
    console.error("Failed to get token:", errorData)
    throw new Error(`Failed to get token: ${response.statusText}`)
  }

  const data = await response.json()
  return data.access_token
}

const getAllPages = async (url: string, token: string) => {
  let allData: any[] = []
  let nextUrl: string | null = url

  while (nextUrl) {
    const response = await fetch(nextUrl, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })

    if (!response.ok) {
      throw new Error(`Failed to fetch data from ${nextUrl}: ${response.statusText}`)
    }

    const data = await response.json()
    allData = allData.concat(data.data)

    nextUrl = data.links?.next || null
  }

  return allData
}

const getActiveGroups = async (token: string) => {
  const data = await getAllPages(`${SOCIAL_BASE_URL}/groups`, token)
  return data.filter((group: any) => group.attributes.status === "active")
}

const getDeletedMembers = async (token: string, groupCode: string) => {
  const data = await getAllPages(`${SOCIAL_BASE_URL}/${groupCode}/members?filter[state]=deleted`, token)
  return data
}

const getAccount = async (token: string, groupCode: string, accountId: string, accountCode: string) => {
  // 1. Try to get the account via id
  let response = await fetch(`${ACCOUNTING_BASE_URL}/${groupCode}/accounts/${accountId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  if (response.ok) {
    const data = await response.json()
    return data.data
  }

  // 2. If not found, try to get the account via code
  response = await fetch(`${ACCOUNTING_BASE_URL}/${groupCode}/accounts?filter[code]=${accountCode}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  if (!response.ok) {
    throw new Error(`Failed to fetch account for group ${groupCode}: ${response.statusText}`)
  }

  const data = await response.json()
  return data.data.length > 0 ? data.data[0] : null
}

const fixDeletedAccounts = async (email: string, password: string, dryRun: boolean, groupCode?: string) => {
  const token = await getToken(email, password)
  console.log(`Authenticated as ${email}`)

  const groups = groupCode ? [groupCode] : (await getActiveGroups(token)).map((group: any) => group.attributes.code)
  console.log(`Found ${groups.length} active groups to process`)

  for (const group of groups) {
    console.log(`Processing group: ${group}`)
    const deletedMembers = await getDeletedMembers(token, group)
    console.log(`Found ${deletedMembers.length} deleted members in group ${group}`)

    const accountsToFix: any[] = []

    for (const member of deletedMembers) {
      const accountId = member.relationships.account.data.id
      const accountCode = member.attributes.code
      const account = await getAccount(token, group, accountId, accountCode)
      if (account && account.attributes.status !== "deleted") {
        accountsToFix.push({ member, account })
      }
    }

    console.log(`Found ${accountsToFix.length} accounts to fix in group ${group}`)

    // Check balances.
    for (const { member, account } of accountsToFix) {
      const balance = account.attributes.balance
      if (balance !== 0) {
        console.log(`Account ${account.attributes.code} has a non-zero balance of ${balance}. Skipping deletion.`)
        continue
      }

      if (dryRun) {
        console.log(`[Dry Run] Would delete account ${account.attributes.code}`)
      } else {
        const response = await fetch(`${ACCOUNTING_BASE_URL}/${group}/accounts/${account.id}`, {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (!response.ok) {
          console.error(`Failed to delete account ${account.attributes.code}: ${response.statusText}`)
        } else {
          console.log(`Deleted account ${account.attributes.code}`)
        }
      }
    }
  }
}

// CLI

const args = process.argv.slice(2)
const email = args[0]
const password = args[1]
const dryRun = args.includes("--dry-run")
const groupIndex = args.indexOf("--group")
const groupCode = groupIndex !== -1 ? args[groupIndex + 1] : undefined

if (!email || !password) {
  console.error("Usage: npx tsx scripts/fix-deleted-accounts.ts <email> <password> [--dry-run] [--group <groupCode>]")
  process.exit(1)
}

fixDeletedAccounts(email, password, dryRun, groupCode)
  .then(() => console.log("Done"))
  .catch((error) => console.error("Error:", error))
